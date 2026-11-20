return function(data)
	local buf = buffer.create(45)
	buffer.writef64(buf, 1, data.id)
	buffer.writeu8(buf, 9, data.type or 1)
	buffer.writeu8(buf, 10, data.lplr and 1 or 0)
	buffer.writeu8(buf, 11, data.bot and 1 or 0)
	buffer.writef32(buf, 12, data.yaw)
	buffer.writef32(buf, 16, data.pitch or 0)
	buffer.writef64(buf, 20, data.pos.X)
	buffer.writef64(buf, 28, data.pos.Y)
	buffer.writef64(buf, 36, data.pos.Z)
	return buf
end