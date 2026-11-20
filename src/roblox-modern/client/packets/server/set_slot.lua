return function(data)
	local buf = buffer.create(10 + #(data.item.nbt or ''))
	buffer.writeu8(buf, 1, data.windowId)
	buffer.writeu8(buf, 2, data.slot)

	if data.item.id ~= 0 then
		buffer.writeu32(buf, 3, item.id)
		buffer.writei8(buf, 7, item.count)
		buffer.writeu16(buf, 8, #(item.nbt or ''))
		buffer.writestring(buf, 10, item.nbt or '')
	end

	return buf
end