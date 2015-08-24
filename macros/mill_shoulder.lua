--mill flats up to shoulders
--written by Jesse Meade-Clift

--THIS CURRENTLY SUCKS

--would like to require lib and use tool_dia_mazak()
--require broken by load, but lib is already loaded by iup...

--##
z_clearance = 4
feed = 0.05
z_zero = -1.5
depth = 1.5
cutter_dia = 3
cut_depth = 0.06
start_clear = "x"
shoulder = {"x2"}
rectangle = {x1=0, y1=-3.5, x2=25.625, y2=3.5}
safety=0.03
cut_percent = 0.45
--##

cutter_half = cutter_dia/2
cutter_offset = cut_percent*cutter_half
number_cuts = num_cuts(depth, cut_depth)
z_start = (number_cuts - 1)*cut_depth+z_zero



function pass(z, z_return)
	local x_primary = true

	if (rectangle.x2 - rectangle.x1) < (rectangle.y2 - rectangle.y1) then
		x_primary = false
	end

	G00 

end

paths = { 	xx2=[[]],
			xx1=[[]],
			xy1=[[]],
			xy2=[[]],
			yx2=[[]],
			yx1=[[]],
			yy1=[[]],
			yy2=[[]]
		}

function passes(z_st, num)
	local depth = z_st
	for i=1, num do
		parallel_clear(rectangle, depth, depth + cut_depth + safety)
		depth = depth - cut_depth
	end
end

--table values must be in $()s for $ vars. Perhaps the . is getting lost
--this is deprecated
start = {x=rectangle.x1+ cutter_offset,y=rectangle.y1-cutter_half - safety}

--[[This function controls one z level pass of a square machined up to a
shoulder at the largest X value of the square. Starts clear on the X axis,
moves in a right angle fashion.]]
function perpendicular_clear(rect, z, ret)
	local sx = rectangle.x1-cutter_half-safety
	local sy = rectangle.y2-cutter_offset
	G00 Z$ret
	for i=1, num_cuts(rect.y2-rect.y1, cutter_dia*cut_percent) do
		G00 X$sx Y$sy
		G00 Z$z
		G01 X$(rect.x2-cutter_half) F$feed
		G01 Y$(rect.y2 + cutter_half + safety) F$feed
		G00 Z$ret
		sy = sy - cutter_dia*cut_percent
	end
end

function parallel_clear(rect, z, ret)
	local horiz_num = num_cuts(rect.x2-rect.x1 - cutter_half, cutter_dia*cut_percent)
	local sx = rectangle.x2 - (horiz_num)*cutter_dia*cut_percent - cutter_half
	local sy = rectangle.y1 - cutter_half - safety
	
	G00 Z$ret
	for i=1, horiz_num +1 do
		G00 X$sx Y$sy
		G00 Z$z
		G01 Y$(rect.y2 + cutter_half + safety) F$feed
		G00 Z$ret
		sx = sx + cutter_dia*cut_percent
	end
end

G90
G95

G00 X0Y0
G00 Z$z_clearance

passes(z_start, number_cuts)

G00 Z$z_clearance
M99