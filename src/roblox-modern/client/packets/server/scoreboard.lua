local function writeString(buf, offset, str)
	buffer.writeu8(buf, offset, #str)
	buffer.writestring(buf, offset + 1, str)
	return offset + 1 + #str
end

return function(data)
	local buflen, offset = 3 + #data.title, 2
	for _, line in data.lines do
		buflen += #line + 1
	end

	local buf = buffer.create(buflen)
	buffer.writeu8(buf, 1, #data.lines)

	for _, line in data.lines do
		offset = writeString(buf, offset, line)
	end
	writeString(buf, offset, data.title)

	return buf
end