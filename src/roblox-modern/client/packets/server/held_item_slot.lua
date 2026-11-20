return function(data)
	local buf = buffer.create(2)
	buffer.writei8(buf, 1, data.slot)
	return buf
end