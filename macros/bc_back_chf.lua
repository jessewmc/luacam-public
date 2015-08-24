--Underside chamfering on a vertical mill, bolt circle holes
--written by Jesse Meade-Clift
--***CHANGES MADE. PROCEED WITH CARE***
--

--functional but goes too deep and in too far
--SHOULD BE FIXED aug 24 2014

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
bcd = 14
bc_no = 6
start_alpha = 0
do_holes = {}--eg: {1, 2, 6, 12}, or {} for all
--##

(0.7 dia emill)
(M9)
(M39)
(S4000 M3)

--dependent vars
safety = (cutter_chf - chamfer)/2.0
hole_rad = id/2
chf_rad = id/2 - cutter_dia/2 + chamfer + safety

function hole(x_c, y_c)
	G00 X$x_c Y$y_c
	G00 Z$z_clearance
	G00 Z$[-hole_depth - cutter_width + chamfer + safety]
	G03 X$[chf_rad + x_c] Y$y_c I$[chf_rad/2] J0
	G03 X$[chf_rad + x_c] Y$y_c I$[-chf_rad] J0
	G03 X$x_c y$y_c I$[-chf_rad/2] J0
	G00 Z$z_clearance
end

act_holes = {}
if next(do_holes) == nil then
	for i=1, bc_no do
		act_holes[i] = true
	end
else
	for i=1, #do_holes do
		act_holes[do_holes[i]] = true
	end
end

G90 G95 F$feed

for i=1, bc_no do
	if act_holes[i] then
		local x, y = bhc_coord(i, bcd, bc_no, start_alpha)
		hole(x, y)
	end
end

M99 
