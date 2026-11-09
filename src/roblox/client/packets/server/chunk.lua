local CHUNK_SIZE = math.pow(16, 3)

local function getBlockOffset(pos)
	return bit32.bor(bit32.lshift(bit32.band(pos.Y, 15), 8), bit32.lshift(bit32.band(pos.Z, 15), 4), bit32.band(pos.X, 15))
end

local function getTableLen(tab)
	local num = 0
	for i in tab do num += 1 end
	return num
end

return function(data)
	local cellCount = getTableLen(data.chunk.cells)
	local paletteCount = #data.chunk.palette
	local buf = buffer.create(11 + (paletteCount * 2) + (cellCount * (CHUNK_SIZE + 1)))

	buffer.writei32(buf, 1, data.x)
	buffer.writei32(buf, 5, data.z)
	buffer.writeu8(buf, 9, cellCount)
	buffer.writeu8(buf, 10, paletteCount)

	for i, id in data.chunk.palette do
		if type(id) == 'table' then
			buffer.writeu16(buf, 9 + (i * 2), bit32.bor(bit32.lshift(id[1], 4), id[2]))
		else
			buffer.writeu16(buf, 9 + (i * 2), bit32.bor(bit32.lshift(id, 4), 0))
		end
	end

	local chunks = 0
	local cellStart = 11 + (paletteCount * 2)
	for y, cell in data.chunk.cells do
		local start = cellStart + (chunks * (CHUNK_SIZE + 1))
		buffer.writeu8(buf, start, y)
		start += 1
		for pos, id in cell do
			buffer.writeu8(buf, start + getBlockOffset(pos), id)
		end
		chunks += 1
	end

	return buf
end