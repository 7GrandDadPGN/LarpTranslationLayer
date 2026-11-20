return function(data)
	local buf = buffer.create(34)
	buffer.writef64(buf, 1, data.id)
	buffer.writef64(buf, 9, data.velocity.x)
	buffer.writef64(buf, 17, data.velocity.y)
	buffer.writef64(buf, 25, data.velocity.z)
	return buf
end