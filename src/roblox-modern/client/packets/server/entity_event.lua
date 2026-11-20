return function(data)
	local buf = buffer.create(10)
	buffer.writef64(buf, 1, data.id)
	buffer.writeu8(buf, 9, data.event)
	return buf
end