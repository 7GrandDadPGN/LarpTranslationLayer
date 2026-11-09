return function(data)
	local buf = buffer.create(14)
	buffer.writef64(buf, 1, data.id)
	buffer.writef32(buf, 9, data.amount)
	return buf
end