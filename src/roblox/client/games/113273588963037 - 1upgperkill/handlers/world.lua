local handler = {
	Name = 'world',
	blocks = {},
	chunks = {},
	connections = {}
}

local CHUNK_SIZE = math.pow(16, 3)
local BLANK_CHUNK = {palette = {}, cells = {}}
local BLOCK_SIZE = 3
local NORMALS = {
	[0] = Vector3.new(0, -1, 0),
	[1] = Vector3.new(0, 1, 0),
	[2] = Vector3.new(0, 0, -1),
	[3] = Vector3.new(0, 0, 1),
	[4] = Vector3.new(-1, 0, 0),
	[5] = Vector3.new(1, 0, 0)
}

local function getBlockOffset(pos)
	return bit32.bor(bit32.lshift(bit32.band(pos.Y, 15), 8), bit32.lshift(bit32.band(pos.Z, 15), 4), bit32.band(pos.X, 15))
end

local function loopClean(tab)
	for index, v in tab do
		if type(v) == 'table' then
			if index == 'palette' then
				table.clear(v)
				continue
			end

			loopClean(v)
		end
	end

	table.clear(tab)
end

local function parsePositions(v, func)
	if v:IsA('BasePart') then
		local cf = v.CFrame
		local start = -(v.Size / 2)

		for x = 0, v.Size.X - 0.001, BLOCK_SIZE do
			for y = 0, v.Size.Y - 0.001, BLOCK_SIZE do
				for z = 0, v.Size.Z - 0.001, BLOCK_SIZE do
					func((cf:PointToWorldSpace(start + Vector3.new(x, y, z)) // BLOCK_SIZE) * BLOCK_SIZE, v)
				end
			end
		end
	end
end

function handler:start()
	local mapLoaded = false

	self.connections = {
		workspace.World.DescendantAdded:Connect(function(v)
			parsePositions(v, function(pos)
				self.blocks[pos // BLOCK_SIZE] = v
				self:write(types.blocks[v.Name] or 1, pos // BLOCK_SIZE, v, mapLoaded)
			end)
		end),
		workspace.World.DescendantRemoving:Connect(function(v)
			parsePositions(v, function(pos)
				if self.blocks[pos // BLOCK_SIZE] == v then
					self.blocks[pos // BLOCK_SIZE] = nil
					self:write(0, pos // BLOCK_SIZE, v, mapLoaded)
				end
			end)
		end)
	}

	for _, v in workspace.World:GetDescendants() do
		parsePositions(v, function(pos)
			self.blocks[pos // BLOCK_SIZE] = v
			self:write(types.blocks[v.Name] or 1, pos // BLOCK_SIZE, v)
		end)
	end

	mapLoaded = true

	tlayer.listeners.chunk = function(data)
		if mapLoaded then
			tlayer:send('chunk', {
				x = data.x,
				z = data.z,
				chunk = self.chunks[data.x..' '..data.z] or {palette = {}, cells = {}}
			})
		end
	end

	tlayer.listeners.place = function(data)
		if data.face == -1 then
			upg.InputTable.use = true
			upg.DoAction('use', true)
			setthreadidentity(8)
		end
	end

	tlayer.listeners.dig = function(data)
		if data.status == 5 then
			upg.InputTable.use = false
			upg.DoAction('use', false)
			setthreadidentity(8)
		end
	end
end

function handler:clean()
	for _, v in self.connections do
		v:Disconnect()
	end

	self.breakPos = nil
	table.clear(self.connections)
	table.clear(self.chunks)
end

function handler:write(id, pos, block, update)
	local chunkPos = (pos + Vector3.new(0, 128, 0)) // 16
	local relPos = (pos - (chunkPos * 16))
	local chunkIndex = chunkPos.X..' '..chunkPos.Z
	local chunkY = chunkPos.Y * 16

	if not self.chunks[chunkIndex] then
		self.chunks[chunkIndex] = {palette = {}, cells = {}}
	end

	local chunk = self.chunks[chunkIndex]
	if not chunk.cells[chunkY] then
		chunk.cells[chunkY] = {}
	end

	if block and block.Name == 'bed' and pos ~= block.Position / 3 then
		id = types.blocks.bed_foot
	end

	local blockIndex = table.find(chunk.palette, id)
	if not blockIndex then
		table.insert(chunk.palette, id)
		blockIndex = #chunk.palette
	end

	if update then
		if type(id) == 'table' then
			tlayer:send('block_update', {
				id = bit32.bor(bit32.lshift(id[1], 4), id[2]),
				pos = Vector3.new(pos.X, pos.Y + 128, pos.Z)
			})
		else
			tlayer:send('block_update', {
				id = bit32.bor(bit32.lshift(id, 4), 0),
				pos = Vector3.new(pos.X, pos.Y + 128, pos.Z)
			})
		end
	end

	chunk.cells[chunkY][relPos] = blockIndex
end

return handler