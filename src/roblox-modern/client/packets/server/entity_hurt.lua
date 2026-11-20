return function(data)
	local buf = buffer.create(15)
	buffer.writef64(buf, 1, data.id)
	buffer.writef32(buf, 9, data.yaw or 0)
	buffer.writeu8(buf, 14, data.damageType or 0)
	return buf
end