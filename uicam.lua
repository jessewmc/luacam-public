--text interface for luaCAM
--written by Jesse Meade-Clift

require "lib"

local input_f
local output_f
local input_str
local number
local input_filename
local save
local macro_ext = "C:\\Documents and Settings\\allan.phillips\\Desktop\\"
local savename = "uicam.cfg"
local savetxt = "./macros/test.lua\n100\n"

function savefile()
	local msg --is this kosher?
	save, msg = io.open(savename, "r")
	if not save then
		local f = io.open(savename, "w")
		f.write(f, savetxt)
		f.close(f)
		save = io.open(savename, "r")
	end
	input_filename = save.read(save,"*line")
	number = extract_number(save.read(save,"*line"))
	save.close(save)
end

function variables()
	status()
	input_f.seek(input_f, "set") --go to beginning of file just in case
	input_str = input_f.read(input_f, "*all")
	vars = pull_vars(input_str)
	local newvars = ""
	io.write(vars)
	io.write("\nProgram variables are above. Do you want to change them? [y]es [b]ack [q]uit\n")
	
	local s = io.read()
	if s == "b" then return input end
	if s == "y" then
		while(true) do
		newvars = ""
			for j in str_lines(vars) do
				v = trim(parse_first(j))
				io.write(j .. "\nEnter a new value for this variable or hit enter to keep the current value.\n")
				local t = io.read()
				if t ~= "" then
					newvars = newvars .. v .. " = " .. t .. "\n"
				else
					newvars = newvars .. j .. "\n"
				end
			end
			io.write("\n" .. newvars)
			io.write("New variables are above. Is this correct? [n]o [b]ack [q]uit\n")
			local u = io.read()
			if u == "b" then return input end
			if u == "q" then return exit end
			if u ~= ("n" or "N") then
				input_str = write_vars(input_str, newvars)
				return output
			end
		end
	end
	if s == "q" then return exit end
	
	return output
end
		

function status()
	print "\n***"
	print("MACRO: " .. (input_filename or "none"))
	print("PROGRAM NUMBER: " .. (number or "none"))
	print "***"
end

function cleanup()
	inp = io.type(input_f)
	out = io.type(output_f)
	if input_f and (inp ~= "closed file") then
		input_f.close(input_f)
	end
	if output_f and (out ~= "closed file") then
		output_f.close(output_f)
	end
	local writesave, msg = io.open(savename, "w")
	writesave.write(writesave, input_filename .. "\n")
	writesave.write(writesave, number .. "\n")
	writesave.close(writesave)
end

function exit()
	cleanup()
	os.exit()
end

function nothing()
end

--should save default values in a file
function input()
	status()
	cleanup()
	local msg

	while(true) do
		inp = input_filename

		print("")
		local t = scandir("macros")
		for i, v in ipairs(t) do
			print(i ..") " .. v)
		end

		print("\nwhich macro do you want? enter a number or [q]uit")
		local s = io.read()
		local n = tonumber(s)
		if n then
			inp = "./macros/"..t[n]
		end
		
		if s == "q" then return exit end

		input_f, msg = io.open(inp, "r")
		if input_f then
			input_filename = inp
			return variables
		end
		print(msg)
	end
end

function output()
	status()
	while(true) do
		error = [[That is not a valid option or a number.]]
		print("\nwhat should the program number be? [b]ack [q]uit")
		s = io.read()
		if s ~= "" then
			number = extract_number(s) or number
		end
		if s == "b" then return variables end --
		if s == "q" then return exit end
		--check if output file exists(write mode open auto-clobbers)
		local g, gmsg = io.open(macro_ext .. number .. ".eia", "r")
		if g then
			error = number .. ".eia: File already exists"
			g.close(g)
		else
			output_f = assert(io.open(macro_ext .. number .. ".eia", "w"))	
			--input_str = input_f.read(input_f, "*all")
			local out = linenumbers(
							headers(number,  _, input_filename) ..
							comment_vars(input_str) ..
							preproc(input_str)
						)
			print(out)
			output_f.write(output_f, out)
			cleanup()
			return startup
		end

		print(error)
	end
end

function startup()
	savefile()
	return input
end

state = startup
while(true) do
	state = state()
end

