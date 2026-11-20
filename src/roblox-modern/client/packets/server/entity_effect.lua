return function(data)
	local buf = buffer.create(14)
	buffer.writef64(buf, 1, data.id)
	buffer.writeu8(buf, 9, data.effectId)
	buffer.writeu8(buf, 10, data.amplifier)
	buffer.writeu16(buf, 11, data.duration)
	buffer.writeu8(buf, 13, data.flags or 0)
	return buf
end