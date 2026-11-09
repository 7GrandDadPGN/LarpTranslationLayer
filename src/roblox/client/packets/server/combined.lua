return function(packets)
	local length = 3
	for _, data in packets do
		length += buffer.len(data) + 2
	end

	local buf = buffer.create(length)
	local offset = 3
	buffer.writeu16(buf, 1, #packets)
	for _, data in packets do
		local len = buffer.len(data)
		buffer.writeu16(buf, offset, len)
		buffer.copy(buf, offset + 2, data, 0, len)
		offset += len + 2
	end

	return buf
end