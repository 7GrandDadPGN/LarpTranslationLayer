return function(data)
	local buf = buffer.create(17 + #(data.item.nbt or ''))
	buffer.writef64(buf, 1, data.id)
	buffer.writeu8(buf, 9, data.slot)

	if data.item.id ~= 0 then
		buffer.writeu32(buf, 10, data.item.id)
		buffer.writei8(buf, 14, data.item.count)
		buffer.writeu16(buf, 15, #(data.item.nbt or ''))
		buffer.writestring(buf, 17, data.item.nbt or '')
	end

	return buf
end