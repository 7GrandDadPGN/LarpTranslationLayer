return function(buf)
	return {
		id = buffer.readf64(buf, 1)
	}
end