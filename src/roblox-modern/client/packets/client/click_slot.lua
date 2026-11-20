return function(buf)
	return {
		windowId = buffer.readu8(buf, 1),
		slot = buffer.readu8(buf, 2),
		action = buffer.readu8(buf, 3),
		mouseButton = buffer.readu8(buf, 4)
	}
end