return function(data)
	local buf = buffer.create(26)
	buffer.writef64(buf, 1, data.velocity.x)
	buffer.writef64(buf, 9, data.velocity.y)
	buffer.writef64(buf, 17, data.velocity.z)
	return buf
end