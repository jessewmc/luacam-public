require "lib"
--TODO: separate this as function, command line interface and batch interface
--separate this into a mainfile/ui? Preproc should prob just be preproc
--in fact this should probably just be a function then?
if (#arg ~= 2) then
	local usefile = "usage.txt"
	local usage = io.open(usefile, "r")
	print (usage.read(usage, "*all"))
	usage.close(usage)
	os.exit()
end

local addresses = {"G", "g", "M", "m", "X", "x", "Y", "y", "Z", "z"}
local f = io.open(arg[1], "r")
o = io.open(arg[2], "w") -- this needs to be global I think, because loadstring looks at global var table
local out = ""

for j in f.lines(f) do
  i = trim(j) --trim whitespace at beginning (and end) of line
	for v in values(addresses) do
		if (string.find(i, "^"..v.."%d+")) then
			i = "o.write(o, string.upper(line(\""..expand(i).."\\n\")))"
--			i = "io.write(string.upper(line(\""..expand(i).."\\n\")))"
		end
	end
	out = out .. i .. "\n"
end

assert(loadstring(out))() --assert gives more verbose error messages
--print(out)
--simple interface?
o.close(o)

f.close(f)
