return function(data)
	local offset = #data.sound
	local buf = buffer.create(20 + offset)
	buffer.writeu8(buf, 1, offset)
	buffer.writestring(buf, 2, data.sound)
	buffer.writei32(buf, 3 + offset, data.pos.X * 8)
	buffer.writei32(buf, 7 + offset, data.pos.Y * 8)
	buffer.writei32(buf, 11 + offset, data.pos.Z * 8)
	buffer.writef32(buf, 15 + offset, data.volume or 1)
	buffer.writeu8(buf, 19 + offset, math.clamp((data.pitch or 1) * 63, 0, 255))
	return buf
end