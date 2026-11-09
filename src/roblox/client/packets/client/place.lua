return function(buf)
	return {
		pos = Vector3.new(buffer.readi32(buf, 1), buffer.readi32(buf, 5), buffer.readi32(buf, 9)),
		face = buffer.readi8(buf, 13)
	}
end