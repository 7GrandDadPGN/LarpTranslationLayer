return function(data)
	local bufSize = 3
	for _, item in data.slots do
		bufSize += 7 + #(item.nbt or '')
	end

	local buf = buffer.create(bufSize)
	buffer.writeu8(buf, 1, data.windowId)
	buffer.writeu8(buf, 2, #data.slots)

	local offset = 3
	for index, item in data.slots do
		if item.id ~= 0 then
			buffer.writeu32(buf, offset, item.id)
			buffer.writei8(buf, offset + 4, item.count)
			buffer.writeu16(buf, offset + 5, #(item.nbt or ''))
			buffer.writestring(buf, offset + 7, item.nbt or '')
		end

		offset += 7 + #(item.nbt or '')
	end

	return buf
end