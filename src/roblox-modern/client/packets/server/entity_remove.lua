return function(data)
	local buf = buffer.create(9)
	buffer.writef64(buf, 1, data.id)
	return buf
end