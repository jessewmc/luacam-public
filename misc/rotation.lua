require "lib"

function rotate(x, y, theta)
	x1 = x*cos(theta) - y*sin(theta)
	y1 = x*sin(theta) + y*cos(theta)
	return x1, y1
end

for i = 0, 300, 60 do
	print("angle: " .. i)
	print(rotate(0.6, 0, i))
	print(rotate(1.5,  0, i))
end