return function(data)
	local buf = buffer.create(3 + (#data.slots * 5))
	buffer.writeu8(buf, 1, data.windowId)
	buffer.writeu8(buf, 2, #data.slots)

	for index, item in data.slots do
		if item.id ~= 0 then
			buffer.writeu32(buf, 3 + (index * 5), item.id)
			buffer.writei8(buf, 7 + (index * 5), item.count)
		end
	end

	return buf
end