return function(data)
	local buf = buffer.create(12)
	buffer.writef64(buf, 1, data.id)
	buffer.writeu8(buf, 9, data.flag)
	buffer.writeu8(buf, 10, data.state and 1 or 0)
	buffer.writeu8(buf, 11, data.living and 1 or 0)
	return buf
end