return function(data)
	local buf = buffer.create(5 + #data.message)
	buffer.writeu32(buf, 1, #data.message)
	buffer.writestring(buf, 5, data.message)
	return buf
end