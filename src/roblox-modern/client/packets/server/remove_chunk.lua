return function(data)
	local buf = buffer.create(9)
	buffer.writei32(buf, 1, data.x)
	buffer.writei32(buf, 5, data.z)
	return buf
end