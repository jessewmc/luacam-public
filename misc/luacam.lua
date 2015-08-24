#!/usr/local/bin/lua

require "groove"


--For output. Machine controller runs on windows, so carriage returns included.
newline = "\r\n"

--reads a hardcoded subprogram to call at each bolthole for now
local f = io.open("sub.eia", "r")

local subname = f:read("*line")
--check for a comment in the title string (looks like this) and discard if necessary
--not strictly necessary as the comment wont be read for the sub call either, but ugly
local v, w = string.find(subname, "%(")
if v then
	subname = string.sub(subname, 1, v - 1)
end
local rest = f:read("*all")
f:close()

--ugly UX follows, does not break gracefully or sanitize input
io.write("clearance Z? ")
clearance = io.read("*number")
io.write("bolt circle dia? ")
dia = io.read("*number")
io.write("number of holes? ")
num = io.read("*number")
io.write("x offset angle? ")
alpha = io.read("*number")
io.write("subprogram params? ")
io.read()
params = io.read()
io.write("skip holes? eg. 4 5 7 9 ")
skip = io.read()
skips = {}

--quick pattern match of the string, sets key value pair of number to be skipped --> true in the skips table
for n in skip:gmatch("%d+") do
	skips[tonumber(n)]=true
	io.write("skip: ", n, newline)
end

rad = dia/2
pitch = 360/num
coords = {}

--runs through each bolthole angle and produces coords in the coords table
current_alpha = alpha
for i=1, num do
	a, b = angle_coords(current_alpha, rad)
	coords[i] = {x=a, y=b}
	current_alpha = current_alpha + pitch
end

--writes to a hardcoded file for now
io.output("boltcircle.eia")
io.write("G94", newline)
io.write("G90 G00 Z"..clearance, newline)
io.write(print_code{code={"G90", "G00"}, z=clearance}, newline)
for hole, coord in ipairs(coords) do
	if not skips[hole] then
		print(string.format("hole "..hole.." x: %.4f y: %.4f", coord.x, coord.y))
		str = string.format("G90 G00 X%.4f Y%.4f", coord.x, coord.y)
		io.write(str, newline)
		io.write("M98 P"..subname, " ", params, newline)
		io.write("G90 G00 Z"..clearance, newline, newline)
	end
end
io.write("M99", newline, newline)

io.write(subname, newline)

io.write(rest)
