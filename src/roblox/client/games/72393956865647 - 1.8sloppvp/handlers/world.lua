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

local function getCellCenter(vec)
	return (vec - Vector3.new(1.5, -1, 1))
end

local params = OverlapParams.new()
params.FilterType = Enum.RaycastFilterType.Include

local function parsePositions(v, func)
	if v:IsA('Part') then
		local cf = v.CFrame
		local start = -(v.Size / 2)
		local startpos = cf:PointToWorldSpace(-(v.Size / 2))
		local endpos = cf:PointToWorldSpace((v.Size / 2))
		local actualstart = Vector3.new(math.min(startpos.X, endpos.X), math.min(startpos.Y, endpos.Y), math.min(startpos.Z, endpos.Z))
		local actualend = Vector3.new(math.max(startpos.X, endpos.X), math.max(startpos.Y, endpos.Y), math.max(startpos.Z, endpos.Z))
		params.FilterDescendantsInstances = {v}

		for x = -6, (actualend.X - actualstart.X) + 6, BLOCK_SIZE do
			for y = -6, (actualend.Y - actualstart.Y) + 6, BLOCK_SIZE do
				for z = -6, (actualend.Z - actualstart.Z) + 6, BLOCK_SIZE do
					local point = (actualstart // 3 * 3) + Vector3.new(0, -0.5, -2.5) + Vector3.new(x, y, z)
					if point:Max(actualstart):Min(actualend) == point then
						func((point - Vector3.new(0, -0.5, -2.5)) - Vector3.new(0, 3, 3), v)
					end
					--func(Vector3.new(math.round(actualstart.X / 3) * 3, math.round(actualstart.Y / 3) * 3, math.round(actualstart.Z / 3) * 3) + Vector3.new(x, y, z), v)
				end
			end
		end

		--[[for x = -3, v.Size.X + 3, BLOCK_SIZE do
			for y = -3, v.Size.Y + 3, BLOCK_SIZE do
				for z = -3, v.Size.Z + 3, BLOCK_SIZE do
					local point = cf:PointToWorldSpace(start + Vector3.new(x, y, z) + Vector3.new(1.5, 1.5, 1.5))
					local clamp = point:Max(actualstart):Min(actualend)
					if point == clamp then
						func(point, v)
					end
				end
			end
		end]]
	end
end

function handler:start()
	local mapLoaded = false
	local updateUsing = debug.getupvalue(debug.getupvalue(slop.ItemUseController.start, 5), 10)
	local startUsing = debug.getupvalue(debug.getupvalue(slop.ItemUseController.start, 5), 18)

	self.connections = {
		workspace.Maps.DescendantAdded:Connect(function(v)
			parsePositions(v, function(pos)
				self.blocks[pos // BLOCK_SIZE] = v
				self:write(types.blocks[v.Name] or 1, pos // BLOCK_SIZE, v, mapLoaded)
			end)
		end),
		workspace.Maps.DescendantRemoving:Connect(function(v)
			parsePositions(v, function(pos)
				if self.blocks[pos // BLOCK_SIZE] == v then
					self.blocks[pos // BLOCK_SIZE] = nil
					self:write(0, pos // BLOCK_SIZE, v, mapLoaded)
				end
			end)
		end)
	}

	for _, v in workspace.Maps:GetDescendants() do
		parsePositions(v, function(pos)
			self.blocks[pos // BLOCK_SIZE] = v
			self:write(types.blocks[v.Name] or 1, pos // BLOCK_SIZE, v)
		end)
	end

	mapLoaded = true

	self.olduse = hookfunction(debug.getupvalue(slop.ItemUseController.start, 5), function() end)

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
			local stack = slop.InventoryController.getSelectedStack()
			local itemData = stack and slop.ItemLookup[stack.itemId] or nil
			if itemData then
				startUsing(stack, itemData)
			end

			setthreadidentity(8)
		end
	end

	tlayer.listeners.dig = function(data)
		if data.status == 5 then
			handler.olduse()
			setthreadidentity(8)
		end
	end
end

function handler:clean()
	for _, v in self.connections do
		v:Disconnect()
	end

	if self.olduse then
		restorefunction(debug.getupvalue(slop.ItemUseController.start, 5))
		self.olduse = nil
	end

	self.useData = nil
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