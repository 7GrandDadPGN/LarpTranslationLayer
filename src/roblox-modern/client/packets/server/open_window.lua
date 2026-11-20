return function(data)
	local buf = buffer.create(6 + #data.name)
	buffer.writeu8(buf, 1, data.windowId)
	buffer.writeu8(buf, 2, data.slots)
	buffer.writeu8(buf, 3, #data.name)
	buffer.writestring(buf, 4, data.name)
	return buf
end