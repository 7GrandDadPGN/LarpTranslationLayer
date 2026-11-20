return function(buf)
	return {
		x = buffer.readi32(buf, 1),
		z = buffer.readi32(buf, 5)
	}
end