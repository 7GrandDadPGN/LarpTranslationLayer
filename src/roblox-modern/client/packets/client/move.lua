return function(buf)
	return {
		pos = Vector3.new(buffer.readf64(buf, 1), buffer.readf64(buf, 9), buffer.readf64(buf, 17)),
		yaw = buffer.readf32(buf, 25),
		pitch = buffer.readf32(buf, 29),
		onGround = buffer.readu8(buf, 33) == 1
	}
end