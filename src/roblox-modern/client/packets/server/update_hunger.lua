return function(data)
	local buf = buffer.create(9)
	buffer.writef32(buf, 1, data.hunger)
	buffer.writef32(buf, 5, data.saturation)
	return buf
end