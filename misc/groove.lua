--[[
G codes accept certain addresses as parameters, by convention in the order that follows. I have only included the addresses that this program makes use of, but extras are easily handled simply by adding them to this table.
Typically X, Y, and Z are destination coordinates. I, J, and rarely K are typically intermediate coordinates of some kind (e.g. arc centre). P may be one of many code-specific parameters. F is always feed rate, may be in distance per minute or distance per spindle revolution.
]]
address_list = {"x", "y", "z", "i", "j", "p", "f"}

--[[
specify a linear distance for ramping in/out of cuts, and a radius for the circle, and converts it to an angular distance
]]
function ramp_coords(distance, radius)
	local dia = 2*radius
	local arcangle = distance/(math.pi * dia) * 360
	return angle_coords(arcangle, radius)
end

--need to know cut depth for ramping...
function circle(radius, clockwise)
	return arc(360, radius, clockwise)
end

function arc(angle, radius, clockwise)
	local code = clockwise and "G02" or "G03"
	local alpha = {}
	alpha.x, alpha.y = angle_coords(angle, radius)
	return code_format(code, "x", alpha.x, "y", alpha.y, "r", radius)
end

function code_format(...)
	local block = ""
	for i, v in ipairs{...} do
		if type(v) == "string" then
			block = block..string.upper(v)
		elseif type(v) == "number" then
			block = block..string.format("%.4f", v).." "
		end
		if i == 1 then
			block = block.." "
		end
	end
	return block
end

function ramp_arc(ramp_dist, angle, radius, clockwise, z)
	local code = clockwise and "G02" or "G03"
	local ramp = {}
	local alpha = {}
	ramp.x, ramp.y = ramp_coords(ramp_dist, radius)
	alpha.x, alpha.y = angle_coords(angle, radius)
	return string.format("%s %s %s %s\n%s %s %s",
			code, truncate("X", ramp.x), truncate("Y", ramp.y), truncate("Z", z),
			code, truncate("X", alpha.x), truncate("Y", alpha.y))
end	

--[[
angle in degrees, radius of arc
]]
function angle_coords(angle, radius)
	local x = math.cos(math.rad(angle)) * radius
	local y = math.sin(math.rad(angle)) * radius
	return x, y
end

--[[
Usage: print_code{code="G00", X=-42, Y=-21, P=1}
	or print_code{code={"g95", "g01"} x=10, y=20}
code is necessary, other parameters are optional. See address_list for full parameters
]]
function print_code(args)
	local block = ""
	if type(args.code) == "table" then
		for i, item in ipairs(args.code) do
			if i > 1 then
				block = block.." "
			end
			block = block..string.upper(item)
		end
	else
		block = block..string.upper(args.code)
	end
	for i, v in ipairs(address_list) do
		if args[v] then
			block = block..truncate(v, args[v])
		end
	end
	return block.."\n"
end 

--machine only works with up to 4 decimal places
--upcases all letters for stylistic convention
function truncate(address, value)
	return string.format(" "..string.upper(address).."%.4f", value)
end
