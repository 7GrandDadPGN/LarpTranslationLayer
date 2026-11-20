return function(buf)
	return {
		status = buffer.readi8(buf, 1),
		pos = Vector3.new(buffer.readi32(buf, 2), buffer.readi32(buf, 6), buffer.readi32(buf, 10)),
		face = buffer.readi8(buf, 14)
	}
end