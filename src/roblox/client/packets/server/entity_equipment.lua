return function(data)
	local buf = buffer.create(15)
	buffer.writef64(buf, 1, data.id)
	buffer.writeu8(buf, 9, data.slot)

	if data.item.id ~= 0 then
		buffer.writeu32(buf, 10, data.item.id)
		buffer.writei8(buf, 14, data.item.count)
	end

	return buf
end