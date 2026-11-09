return function(data)
	local buf = buffer.create(8)
	buffer.writeu8(buf, 1, data.windowId)
	buffer.writeu8(buf, 2, data.slot)

	if data.item.id ~= 0 then
		buffer.writeu16(buf, 3, data.item.id)
		buffer.writei8(buf, 7, data.item.count)
	end

	return buf
end