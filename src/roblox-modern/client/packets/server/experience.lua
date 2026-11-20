return function(data)
	local buf = buffer.create(25)
	buffer.writef32(buf, 1, data.experienceBar)
	buffer.writef64(buf, 9, data.level)
	buffer.writef64(buf, 17, data.totalExperience)
	return buf
end