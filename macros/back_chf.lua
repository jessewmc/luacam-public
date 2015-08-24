--For underside chamfering on a vertical mill
--written by Jesse Meade-CLift
--January 2014

--##
z_clearance = 2.0
feed = 0.0035
z_zero = 0
hole_depth  = 1
x_centre = 0
y_centre = 0
id = 6.25
cutter_dia = 0.6969
cutter_width = 0.2343
cutter_chf = 0.0669
chamfer = 0.05
outside_chf = false --true for outside chamfer
--##

--ERROR HANDLING
if chamfer > 0.8*cutter_chf then error("CHAMFER TOO LARGE FOR CUTTER") end

safety = (cutter_chf - chamfer)/2.0
hole_rad = id/2
if outside_chf then
  chf_rad = id/2 + cutter_dia/2 - chamfer - safety
else
  chf_rad = id/2 - cutter_dia/2 + chamfer + safety
end

--for outside chf only
start_x = 0.33 * id

function hole(x_c, y_c)
	G00 X$x_c Y$y_c
	G00 Z$z_clearance
	G00 Z$[-hole_depth - cutter_width + chamfer + safety]
	G03 X$[chf_rad + x_c] Y$y_c I$[chf_rad/2] J0
	G03 X$[chf_rad + x_c] Y$y_c I$[-chf_rad] J0
	G03 X$x_c y$y_c I$[-chf_rad/2] J0
	G00 Z$z_clearance
end

function od(x_c, y_c)
  G00 X$x_c Y$y_c
  G00 Z$z_clearance
  G00 X$start_x Y$[-chf_rad]
  G00 Z$[-hole_depth - cutter_width + chamfer + safety]
  G01 X0
  G02 X0 Y$[-chf_rad] I0 J$chf_rad
  G01 X$[-start_x]
  G00 Z$z_clearance
end


G90 G95 F$feed

if outside_chf then
  od(x_centre, y_centre)
else
  hole(x_centre, y_centre)
end

M99 
