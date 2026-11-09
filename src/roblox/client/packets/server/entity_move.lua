return function(data)
	local buf = buffer.create(42)
	buffer.writef64(buf, 1, data.id)
	buffer.writef32(buf, 9, data.yaw)
	buffer.writef32(buf, 13, data.pitch or 0)
	buffer.writef64(buf, 17, data.pos.X)
	buffer.writef64(buf, 25, data.pos.Y)
	buffer.writef64(buf, 33, data.pos.Z)
	return buf
end