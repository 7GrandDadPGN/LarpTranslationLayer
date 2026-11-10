return function(data)
	local buf = buffer.create(43)
	buffer.writef64(buf, 1, data.id)
	buffer.writef32(buf, 9, data.yaw)
	buffer.writef32(buf, 13, data.pitch or 0)
	buffer.writeu8(buf, 17, data.onGround and 1 or 0)
	buffer.writef64(buf, 18, data.pos.X)
	buffer.writef64(buf, 26, data.pos.Y)
	buffer.writef64(buf, 34, data.pos.Z)
	return buf
end