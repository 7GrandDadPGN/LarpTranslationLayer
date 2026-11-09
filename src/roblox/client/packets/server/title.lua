local function writeString(buf, offset, str)
	buffer.writeu8(buf, offset, #str)
	buffer.writestring(buf, offset + 1, str)
	return offset + 1 + #str
end

return function(data)
	local offset = 2
	local buf = buffer.create(16 + #data.text)
	buffer.writeu8(buf, 1, data.action)
	offset = writeString(buf, offset, data.text)
	buffer.writei32(buf, offset, data.fadeIn)
	buffer.writei32(buf, offset + 4, data.stay)
	buffer.writei32(buf, offset + 8, data.fadeOut)

	return buf
end