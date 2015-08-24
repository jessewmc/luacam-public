io.write("o-ring groove od? ")
local od = io.read("*number")
io.write("o-ring groove id? ")
local id = io.read("*number")

pitch_rad = (od + id)/4
ring_width = (od - id)/2
large_ch = od/2
small_ch = id/2
if(ring_width < 0.1875) then
	large_ch = pitch_rad + 0.1875/2
	small_ch = pitch_rad - 0.1875/2
end

io.write(string.format("\npitch radius: %.4f\n", pitch_rad))
io.write(string.format("large chamfer radius: %.4f\n", large_ch))
io.write(string.format("small chamfer radius: %.4f\n", small_ch))
io.write(string.format("\nring width: %.4f\n", ring_width))