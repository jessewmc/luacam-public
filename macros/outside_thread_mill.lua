--external thread milling
--written by Jesse Meade-Clift

--##
z_clearance = 2.0
feed = 0.0035
z_zero = 0
z_depth  = 1 --+1 pitch. TODO: FIX
od = 1.75
pitch = 1/18 --does this work?
cutter_dia = 0.6915 --singlepoint threading
cut_depth = 0.04
angle_pickup = -132.7
z_pickup = -0.7397
safety = 0.03
thread_depth = 0.028
no_teeth = 12 --fixed for thread mill
--##

--dependent vars
z_bottom = z_zero - z_depth
cutter_rad = cutter_dia/2.0
hole_rad = od/2.0
ramp_height = pitch
cut_dist = hole_rad + cutter_rad - thread_depth
ramp_dist = hole_rad + cutter_rad + safety
clearance_height = z_zero + pitch
pitches = (clearance_height - z_bottom)/pitch
d_passes = pitches/(no_teeth - 1)
start_alpha = (((clearance_height - z_pickup)/pitch) * 360) + angle_pickup
fin_alpha = start_alpha - (pitches * 360)
start_x = cos(start_alpha)*cut_dist
start_y = sin(start_alpha)*cut_dist
neg_start_x = -start_x
neg_start_y = -start_y
fin_x = cos(fin_alpha)*cut_dist
fin_y = sin(fin_alpha)*cut_dist
ramp_x = cos(fin_alpha)*ramp_dist
ramp_y = sin(fin_alpha)*ramp_dist
neg_fin_x = -fin_x
neg_fin_y = -fin_y
z_end = z_bottom - pitch
	
G90
G95
G00 X$start_x Y$start_y
G00 Z$z_clearance
G17
G00 Z$clearance_height
G02 X$fin_x Y$fin_y I$neg_start_x J$neg_start_y Z$z_bottom P$pitches F$feed
G02.1 X$ramp_x Y$ramp_y I$neg_fin_x J$neg_fin_y Z$z_end P1 F$feed 
G00 Z$clearance_height
G00 Z$z_clearance
M99