return function(data)
	local buf = buffer.create(13 + #data.attributes)
	buffer.writef64(buf, 1, data.id)
	buffer.writeu32(buf, 9, #data.attributes)
	buffer.writestring(buf, 13, data.attributes)
	return buf
end