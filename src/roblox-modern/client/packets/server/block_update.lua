return function(data)
	local buf = buffer.create(15)
	buffer.writeu16(buf, 1, data.id)
	buffer.writei32(buf, 3, data.pos.X)
	buffer.writei32(buf, 7, data.pos.Y)
	buffer.writei32(buf, 11, data.pos.Z)
	return buf
end