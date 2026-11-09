return function(data)
	local buf = buffer.create(25)
	buffer.writef64(buf, 1, data.pos.X)
	buffer.writef64(buf, 9, data.pos.Y)
	buffer.writef64(buf, 17, data.pos.Z)
	return buf
end