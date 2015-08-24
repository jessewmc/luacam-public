--external circle milling
--written by Jesse Meade-Clift

--##
z_clearance = 4
feed = 0.02
z_zero = -1.675
depth = .4
dia = 15.6344
cutter_dia = 0
pitch = 0.1
safety = 0.03
--##

--dependent vars
cut_rad = (dia + cutter_dia)/2
safety_height = z_zero + safety
pitches = (depth + safety)/pitch
alpha = (360 * pitches) % 360
eff_depth = z_zero - depth

x_coor = cut_rad*cos(alpha)
y_coor = -cut_rad*sin(alpha)
clear_x = cos(alpha) * safety
clear_y = -sin(alpha) * safety
neg_x = -x_coor
neg_y = -y_coor

G90
G95

G00 X0 Y0 Z$z_clearance
G00 X$cut_rad
G00 Z$safety_height
G17
G02 X$x_coor Y$y_coor Z$eff_depth I-$cut_rad J0 P$pitches F$feed
G02 X$x_coor Y$y_coor I$neg_x  J$neg_y F$feed
G91 
G00 X$clear_x Y$clear_y
G90
G00 Z$safety_height
G00 Z$z_clearance
G00 X0 Y0

M99
