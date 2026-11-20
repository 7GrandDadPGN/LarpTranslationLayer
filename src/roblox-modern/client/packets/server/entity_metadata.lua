return function(data)
	local buf = buffer.create(13 + #data.metadata)
	buffer.writef64(buf, 1, data.id)
	buffer.writeu32(buf, 9, #data.metadata)
	buffer.writestring(buf, 13, data.metadata)
	return buf
end