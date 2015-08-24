--library functions for luaCAM
--written by Jesse Meade-Clift

newline = "\n"
versionno = "0.7"

--TODO: gui per macro!! ***
--todo: errors
--todo: if everything is a function, everything is composable

--trig functions that take degrees. rounding occasionally produces odd results (eg. extremely small numbers instead of zero)
--math.abs check is to remove badly behaved small decimals that should be whole numbers
function sin(x)
	local ret = math.sin(math.rad(x))
	if math.abs(ret) < 0.0001 then ret = 0 end
	return ret
end
function cos(x)
	local ret = math.cos(math.rad(x))
	if math.abs(ret) < 0.0001 then ret = 0 end
	return ret
end

--rotates coordinates around origin by alpha
function angletransform(x, y, alpha)
  return x*cos(alpha)-y*sin(alpha), y*cos(alpha)+x*sin(alpha)
end

function round(num, digits)
  return string.format("%."..digits.."f", num)
end

--returns coordinates of a given bolt hole on a given bolt hole circle
--hole number 1 is first positive angle from positive x-axis
--offset is angle from positive x-axis to first hole
--currently unused by luacam
function bhc_coord(hole_no, bcd, no_holes, offset)
	--hole_no - 1 to start at first hole
	local angle = offset + ((hole_no - 1)/no_holes)*360
	local rad = bcd/2
	return cos(angle)*rad, sin(angle)*rad
end

--generates a macro code for fetching the current tool diameter in machine
--currently unused
function tool_dia_mazak()
	return "#[61000+#51999] (tool dia. current tool)"
end

--format decimal places in g-code addresses
--determines which addresses have their values rounded, ad also var interpolation
function line(line)
	return string.gsub(line, "([aAxXyYzZiIjJpPfF])([+-]?%d+[%.]*[%d]*)", function (m,n)
			return m..string.format("%.4f", n) --refactor
		end)
end

--removes whitespace at beginning and end of string
function trim(s)
	return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

--creates a g-code header with program  number, and an optional descriptive comment
--also adds comments with the date generated and the source file name/location
function headers(program_number, comment, src)
	local headers = ""
	comment = comment or ""
	headers = headers .. "O" 
					.. string.format("%08d", program_number) 
					.. "(" .. comment .. ")"
					.. newline 
					.. friendly_date()
					.. version()
					.. source(src)
	return headers
end

--helper format function
function source(src)
	return "(Source: " .. src .. ")\n"
end

--[%w_]+ matches one or more digits, letters or underscores after the $ sign, stopping at first whitespace. replaced with %1 first occurence found
--%(...%) escapes brackets. Finds minimum number of any characters between matching $( and ), replaced with first %1 occurence found
--eg: turns "$(x + y) $blah" into "\"..x+y.." "..blah..\""
function expand(s)
	local st = string.gsub(s, "$([%w_]+)", "\".. %1 ..\"")
	return string.gsub(st, "$%[(.-)%]", "\".. %1 ..\"")
end 

--iterator, goes through all values of a table ignoring keys
function values (t)
	local i = 0
	return function ()
		i = i + 1
		return t[i]
	end
end

--parallel iteration through two tables
--currently unused
function parallel(a, b)
	local i = 0
	return function()
		i = i + 1
		return a[i], b[i]
	end
end

--pulls a number froma string, returns nil if none found
function extract_number(text)
	return string.match(text, "(%d+)")
end

--unused
function str_sanitize(str)
	return "o.write(o, string.upper(\""..str.."\\n\"))"
end

--todo, automated macro translation mode?
--self-contained loadstring env? could clobber stuff
--preprocessing function, does translation from hybrid templates to raw g-code
--TODO: doesn't handle F$feed on its own line
--determines which addresses can start a line
function preproc(str)
	local addresses = {"G", "g", "M", "m", "S", "s", "T", "t", "X", "x", "Y", "y", "Z", "z"}
	local out = "local output_ = \"\"\n"

	for j in str_lines(str) do
		i = trim(j) --trim whitespace at beginning (and end) of line
		for v in values(addresses) do
			--looks for an address plus one or more digits, i.e. "G0"
			--or checks for EIA comments ()
			if (string.find(i, "^"..v.."%d+") or string.find(i, "^%(")) then
				i = "output_ = output_ .. string.upper(line(\""..expand(i).."\\n\"))"
			end
		end
		out = out .. i .. "\n"
	end
	out = out .. "return output_"
	return assert(loadstring(out))()
end

--returns number of lines with actual code, ignores comments and program number line
function numberoflines(str)
	local exceptions = {"O", "("}
	local lineno = 0
	for j in str_lines(str) do
		local flag = true
		for v in values(exceptions) do
			if(string.find(j, "^["..v.."]")) then
				flag = false
			end
		end
		if(flag) then
			lineno = lineno + 1
		end
	end
	return lineno
end

--returns the number of digits of num (an integer)
function digits(num)
	return math.floor(math.log10(num)) + 1
end

--adds g-code linenumbers, only to lines with g-code
function linenumbers(str)
	local exceptions = {"O", "("}
	local out = ""
	local digits = digits(numberoflines(str))
	
	local lineno = 1--why not local?
	
	for j in str_lines(str) do
		i = trim(j)
		local flag = true
		for v in values(exceptions) do
			if(string.find(i, "^["..v.."]")) then
				flag = false
			end
		end
		if(flag) then
			i = "N" .. string.format("%0" .. digits .. "d", lineno) .. " " .. i
			lineno = lineno + 1
		end
		out = out .. i .. "\n"
	end
	return out
end

--surrounds file in %..%, g-code standard. currently unused, machine doesn't like it
function percent(str)
	local out = ""
	
	for j in str_lines(str) do
		i = trim(j)
		out = out .. i .. "\n"
	end
	return "%\n" .. out .. "%\n"
end

function version()
	return "(by luacam version " .. versionno .. ")\n"
end

function friendly_date()
	return os.date("(Generated on %A %B %d %Y at %X)\n")
end

--iterates through each line of a string
--no good equivalent in std lib
function str_lines(str)
	return string.gmatch(str, "[^" .. newline .. "]+")
end

--helper composition function
function comment_vars(str)
	return comment(pull_vars(str))
end

--g-code comments a block of text
function comment(str)
	local out = ""
	for j in str_lines(str) do
		i = trim(j)
		out = out .. "(" .. j .. ")" .. newline
	end
	return out
end

--extracts special variables between --##s,  for commenting and modifying
function pull_vars(str)
	local out = ""
	local flag = false
	for j in str_lines(str) do
		i = trim(j)
		if(i == "--##") then
			flag = not flag
		elseif(flag) then
			out = out .. j .. newline
		end
	end
	return out
end

--same as pull_vars but makes a table instead of a string.
function pull_vars_table(str)
	local t = {}
	local k = 0
	local flag = false
	for j in str_lines(str) do
		i = trim(j)
		if(i == "--##") then
			flag = not flag
		elseif(flag) then
			k = k + 1
			t[k] = j
		end
	end
	return t
end

function table_to_lines(t)
	local out = ""
	for k in pairs(t) do
		out = out .. k .. newline
	end
end

--write new variables between --##s
function write_vars(str, vars)
	local out = ""
	local flagcount = 0
	for j in str_lines(str) do
		i = trim(j)
		if(i == "--##" and flagcount == 0) then
			flagcount = flagcount + 1
			out = out .. j .. newline
		elseif(flagcount == 0 or flagcount == 2) then
			out = out .. j .. newline
		elseif(i == "--##" and flagcount == 1) then
			flagcount = flagcount + 1
			--assuming there is a newline on end of vars
			out = out .. vars
			out = out .. j .. newline
		end
	end
	return out
end

--extract values from a variable assignment in --## section
function parse_assignment(line)
	local work =  trim(line)
	local var, value = string.match(work, "(.+)%s*=%s*(.+)")
	return var, value
end

--extract var name from var assignment as above
function parse_first(line)
	local work = trim(line)
	return string.match(work, "(.+)%s*=s*.+")
end

--take a function fn,  call it from i to j inclusive over step, call j even if not a multiple of j-i, optionally decrement the step by dec
function cycle(fn, i, j, step, dec)
	dec = dec or 0
	local last = 0
	while (i <= j) do
		fn(i)
		last = i
		i = i + step
		step = step - dec
		if step <=0 then step = 0.001 end
	end
	if last ~= j then
		fn(j)
	end
end

--geometric cycle
function cycle_g(fn,  i,  j, factor)
	local last = 0
	local st = i
	while (i <= j) do
		fn(i)
		last = i
		st = st*factor
		if st <= 0.001 then st = 0.001 end
		i = i + st
	end
	if last ~= j then
		fn(j)
	end
end

--returns an array of directory listing
function scandir(directory)
	local i, t = 0, {}
	local file = io.popen("ls " .. directory) --popen doesn't handle errors with msg
	for filename in file.lines(file) do
		i = i + 1
		t[i] = filename
	end
	return t
end

--returns number of cuts required for a given depth in cut depths of "cut"
function num_cuts(depth, cut)
	return math.ceil(depth/cut)
end
