--WARNING: THIS PROGRAM HAS CHANGED. CAUTION, UNTESTED
--bolt hole circle thread milling macro
--written by Jesse Meade-Clift

--require "macros/thread_sub"
--require broken by load
--could replace with custom require that concats


--##
z_clearance = 2.0
feed = 0.0035
z_zero = 0. --safe default
z_depth  = 1.525 -- safe default
id = 1.25
pitch = 0.125 --required for thread mill
x_centre = 0.0
y_centre = 0.0
cutter_dia = 0.86
cut_depth = 0.04
safety = 0.03
thread_depth = 0.0645 --start at 0.07
no_teeth = 12 --fixed for thread mill
bcd = 18.5
bc_no = 16 --number of holes
theta_offset = 0.0 --same as offset "th" in mazatrol
start_alpha = 11.25 --drawing angle
do_holes = {2}--eg: {1, 2, 7, 12}. enter {} for all
--##

--dependent vars
effective_alpha = start_alpha + theta_offset
--

(0.8 dia  emill)
(M9)
(M39)
(S3800 M3)
(M51)

function hole(	z_clearance,
				feed,
				z_zero,
				z_bottom,
				id,
				pitch,
				x_centre,
				y_centre,
				cutter_dia,
				cut_depth,
				safety,
				thread_depth,
				no_teeth
				)

	--dependent vars
	cutter_rad = cutter_dia/2.0
	hole_rad = id/2.0
	ramp_dist = hole_rad - cutter_rad - safety
	ramp_height = pitch
	clearance_height = z_zero + pitch
	pitches = (clearance_height - z_bottom)/pitch
	d_passes = pitches/(no_teeth - 1)
  --CHANGED: 3 --> 2
	d_pass_depth = pitch * (no_teeth - 2)

	G00 Z$z_clearance

	function pass(depth)
		local cut_dist = (hole_rad - cutter_rad + depth) - ramp_dist
		local tot = cut_dist + ramp_dist
		G17
		G00 Z$z_bottom
		G91
		for i = 1, d_passes + 1 do
			G00 Y-$ramp_dist
			G03.1 X0 Y-$cut_dist I0 J$ramp_dist Z$ramp_height P1 F$feed
			G03 X0 Y0 I0 J$tot Z$ramp_height P1 F$feed
			G00 Y$tot
			G00 Z$d_pass_depth
		end
		G90
	end

	cycle_g(pass, cut_depth, thread_depth, 0.65)

	G00 Z$z_clearance
end


z_bottom = z_zero - z_depth
act_holes = {}
if next(do_holes) == nil then --check if table is empty
	for i=1, bc_no do
		act_holes[i] = true
	end
else
	for i=1, #do_holes do
		act_holes[do_holes[i]] = true
	end
end
--[[dependent vars
cutter_rad = cutter_dia/2.0
hole_rad = id/2.0
ramp_dist = hole_rad - cutter_rad - safety
ramp_height = z_bottom + pitch
clearance_height = z_zero + pitch
pitches = (clearance_height - z_bottom)/pitch
d_passes = pitches/(no_teeth - 1)
d_pass_depth = pitch * (no_teeth - 2)
--]]

G90
G95
G00 X$x_centre Y$y_centre
G00 Z$z_clearance

for i=1, bc_no do
	if act_holes[i] then
		local x, y = bhc_coord(i, bcd, bc_no, effective_alpha)
		G00 X$x Y$y
		hole(	z_clearance,
				feed,
				z_zero,
				z_bottom,
				id,
				pitch,
				x_centre,
				y_centre,
				cutter_dia,
				cut_depth,
				safety,
				thread_depth,
				no_teeth
				)
	end
end

M99
