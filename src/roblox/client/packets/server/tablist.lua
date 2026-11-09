local function writeString(buf, offset, str)
	buffer.writeu8(buf, offset, #str)
	buffer.writestring(buf, offset + 1, str)
	return offset + 1 + #str
end

return function(data)
	local buflen, offset = 2, 2
	for _, plr in data do
		buflen += 12
		buflen += #plr.Name
		buflen += #plr.Prefix
		buflen += #plr.Suffix
	end

	local buf = buffer.create(buflen)
	buffer.writeu8(buf, 1, #data)

	for _, plr in data do
		buffer.writef64(buf, offset, plr.UserId)
		buffer.writeu8(buf, offset + 8, plr.isLocal and 1 or 0)
		offset += 9
		offset = writeString(buf, offset, plr.Name)
		offset = writeString(buf, offset, plr.Prefix)
		offset = writeString(buf, offset, plr.Suffix)
	end

	return buf
end