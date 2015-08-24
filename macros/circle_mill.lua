--Circle milling
--written by Jesse Meade-Clift

--testing
--comments on comment lines
--todo function interface to this stuff?
--todo spit out () comments saying what vars are?pos w/ function interface
--parameter vars
--HERE: symbol for vars open/close. current value is default, option to change !!!! maybe a comment symbol?

--TODO: HORIZONTAL APPROACH? AVOID SCARY VERTICAL MOVEMENT

--high feed: f0.08, p0.06
--##
z_clearance = 2.0
feed = 0.1
z_zero = 0
stock = 0.35
od = 21.5
id = 15.75
x_centre = 0.0
y_centre = 0.0
cutter_dia = 2.0
cut_depth = 0.06 --pitches
safety = 0.05
inside_to_outside = false
--##

--dependent vars
cut_width = 0.7*cutter_dia
outside_rad = (od - cutter_dia)/2
inside_rad = (id + cutter_dia)/2
safety_height = z_zero + stock + safety
pitches = (stock + safety)/cut_depth
alpha = (360 * pitches) % 360

--current_rad = outside_rad
current_z = safety_height

G90 (absolute)
G95 (synchronous per rev feed)

function pass(radius)
	local x_coor = -radius*cos(alpha)
	if math.abs(x_coor) < 0.0001 then x_coor = 0 end
	local y_coor
	if inside_to_outside then
		y_coor = -radius*sin(alpha)
	else
		y_coor = radius*sin(alpha)
	end
	if math.abs(y_coor) < 0.0001 then y_coor = 0 end
	local neg_x = -x_coor
	local neg_y = -y_coor
	G00 X-$radius Y$y_centre 
	G00 Z$z_clearance 
	G00 Z$current_z 
	G17
	if inside_to_outside then
		G03 X$x_coor Y$y_coor Z$z_zero I$radius J-$y_centre P$pitches F$feed 
		G03 X$x_coor Y$y_coor I$neg_x J$neg_y F$feed
	else
		G02 X$x_coor Y$y_coor Z$z_zero I$radius J-$y_centre P$pitches F$feed 
		G02 X$x_coor Y$y_coor I$neg_x J$neg_y F$feed
	end
	G00 Z$current_z
end

if inside_to_outside then
	for i = inside_rad, outside_rad, cut_width do
		pass(i)
	end
	if((outside_rad - inside_rad)%cut_width>0) then
		pass(outside_rad)
	end
else
	--this is silently failing if outside rad smaller than inside. should make explicit
	for i = outside_rad, inside_rad, -cut_width do
		pass(i)
	end
	if((outside_rad-inside_rad)%cut_width>0) then
		pass(inside_rad)
	end
end

G00 Z$z_clearance 
M99