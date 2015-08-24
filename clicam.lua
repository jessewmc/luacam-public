--command line interface for luaCAM
--written by Jesse Meade-Clift

--todo debug option
--BUG: NEGATIVES NOT HANDLED CORRECTLY(i.e no inline calculation)
require "lib"

if (arg[2]) then
	number = extract_number(arg[2])
end
	
if (#arg ~= 2 or not number) then
	local usefile = "usage.txt"
	local usage = assert(io.open(usefile, "r"))
	print (usage.read(usage, "*all"))
	usage.close(usage)
	os.exit()
end

--check if input file exists
local f, msg = io.open(arg[1], "r")
if not f then 
	print(msg)
	os.exit()
end

--check if output file exists (write mode auto-clobbers)
local g, gmsg = io.open(number .. ".eia", "r")
if g then
	print(number .. ".eia: File already exists")
	g.close(g)
	os.exit()
end

local o = assert(io.open(number .. ".eia", "w"))

local input = f.read(f, "*all")

local out = linenumbers(
				headers(number, _, arg[1]) ..
				comment_vars(input) ..
				preproc(input)
				)

print(out)
o.write(o, out)

o.close(o)
f.close(f)

print(string.format("Generated in %.4f seconds\n", os.clock()))