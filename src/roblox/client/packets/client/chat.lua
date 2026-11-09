return function(buf)
	return {
		text = buffer.readstring(buf, 5, buffer.readu32(buf, 1))
	}
end