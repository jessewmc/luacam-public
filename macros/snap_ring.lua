--snap ring macro
--written by Jesse Meade-Clift

--##
z_clearance = 2.0
groove_od = 3.6085
groove_id = 3.5
groove_width = 0.0705
groove_z_top = -1.272
cutter_dia = 0.6967
cutter_thickness = 0.067
clearance = 0.03
ramp_angle = 50
feed = 0.0015
--##

cut_width = 0.7*cutter_thickness
full_rad = groove_od/2 - cutter_dia/2
radi = groove_id/2 - cutter_dia/2
clear_rad = radi - clearance

ramp_x = full_rad*sin(ramp_angle)
ramp_y = full_rad*cos(ramp_angle)
clear_x = clear_rad*sin(ramp_angle)
clear_y = clear_rad*cos(ramp_angle)

current_z = groove_z_top - cutter_thickness + cut_width

zero = 0.0
function gg(z)
--set z global here so expand finds it in global table?
G95 g90
G00 X$z Y$z
G00 Z$z_clearance
end

(E-MILL 0.7)
(M9)
(M39)
(S3800 M3)
(M51)

gg(zero)

flag = true;
while (flag) do
	current_z = current_z - cut_width
	if (current_z <= (groove_z_top - groove_width)) then
		flag = false
		current_z = groove_z_top - groove_width
	end
	G00 X0.0 Y0.0
	G00 Z$current_z
	G00 Y-$clear_rad
	G01 Y-$radi F$feed
	G3.1 X$ramp_x Y-$ramp_y I0.0 J$radi F$feed
	G03 X$ramp_x Y-$ramp_y I-$ramp_x J$ramp_y F$feed
	G01 X$clear_x Y-$clear_y F$feed
end
G00 X0.0 Y0.0
G00 Z$z_clearance
M99
