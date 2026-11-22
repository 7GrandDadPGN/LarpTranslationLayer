local handler = {
	Name = 'world',
	blocks = {},
	chunks = {},
	connections = {}
}

local mapLoaded = false
local tpCheck = false

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
	local cf = v.CFrame
	local start = -(v.Size / 2) + Vector3.new(BLOCK_SIZE / 2, BLOCK_SIZE / 2, BLOCK_SIZE / 2)

	for x = 0, v.Size.X - 1, BLOCK_SIZE do
		for y = 0, v.Size.Y - 1, BLOCK_SIZE do
			for z = 0, v.Size.Z - 1, BLOCK_SIZE do
				func(cf:PointToWorldSpace(start + Vector3.new(x, y, z)), v)
			end
		end
	end
end

function handler:start()
	self.connections = {
		replicatedStorage.MC.Remotes.Event.OnClientEvent:Connect(function(event, data)
			if event == 'fx' and data.kind == 'break' then
				self.blocks[data.pos // 1] = nil
				self:write(0, data.pos // 1, nil, mapLoaded)

				tlayer:send('play_sound', {
					sound = 'block.stone.break',
					pos = data.pos + Vector3.new(0, 128, 0),
					volume = 1,
					pitch = 1,
					source = 4
				})
			elseif event == 'teleport' then
				tpCheck = false
			end
		end)
	}

	for _, folder in {workspace.MCWorld.Solid, workspace.MCWorld.Webs, workspace.MCWorld.Fire} do
		table.insert(self.connections, folder.ChildAdded:Connect(function(v)
			if v:IsA('BasePart') then
				parsePositions(v, function(pos)
					self.blocks[pos // BLOCK_SIZE] = v
					self:write(types.blocks[v.MaterialVariant] or (v.Name == 'Cobweb' and 129 or 1), pos // BLOCK_SIZE, v, mapLoaded)
				end)
			end
		end))

		table.insert(self.connections, folder.ChildRemoved:Connect(function(v)
			if v:IsA('BasePart') then
				parsePositions(v, function(pos)
					if self.blocks[pos // BLOCK_SIZE] == v then
						self.blocks[pos // BLOCK_SIZE] = nil
						self:write(0, pos // BLOCK_SIZE, v, mapLoaded)
					end
				end)
			end
		end))
	end
	self:loadMap()

	tlayer.listeners.chunk = function(data)
		if mapLoaded then
			tlayer:send('chunk', {
				x = data.x,
				z = data.z,
				chunk = self.chunks[data.x..' '..data.z] or {palette = {}, cells = {}}
			})
		end
	end

	tlayer.listeners.dig = function(data)
		if data.status == 0 then
			firePacket({a = 'breakStart', cell = (data.pos - Vector3.new(0, 128, 0))})
		elseif data.status == 2 then
			firePacket({a = 'breakEnd', cell = (data.pos - Vector3.new(0, 128, 0))})
		elseif data.status == 5 then
			task.spawn(unstable.Hands.stopUsing, false)
			setthreadidentity(8)
		elseif data.status == 6 then
			handlers.gui:swap()
		elseif data.status == 7 then
			handlers.entity:jab()
		end
	end
end

function handler:loadMap(didRemove)
	mapLoaded = false
	tlayer:send('reload_world')
	if self.loadthread then
		task.cancel(self.loadthread)
		self.loadthread = nil
	end

	loopClean(self.chunks)

	local map
	for _, v in workspace.MCWorld.Solid:GetChildren() do
		if (not ((v.Name:find('Practice') or v.Name:find('Duel')) and not workspace:GetAttribute('DuelServer'))) and v.Name ~= 'Barrier' and v:IsA('Folder') then
			map = v
			break
		end
	end

	if map then
		self.loadconnection = map.AncestryChanged:Once(function(parent)
			self:loadMap(true)
		end)

		self.loadthread = task.spawn(function()
			local timeTaken = os.clock()

			for _, v in map:QueryDescendants('Part') do
				if (os.clock() - timeTaken) > 2 then
					task.wait(0.2)
					timeTaken = os.clock()
				end

				parsePositions(v, function(pos)
					self.blocks[pos // BLOCK_SIZE] = v
					self:write(types.blocks[v.MaterialVariant] or 1, pos // BLOCK_SIZE, v)
				end)
			end

			for _, folder in {workspace.MCWorld.Solid, workspace.MCWorld.Webs, workspace.MCWorld.Fire} do
				for _, v in folder:GetChildren() do
					if v:IsA('BasePart') then
						parsePositions(v, function(pos)
							self.blocks[pos // BLOCK_SIZE] = v
							self:write(types.blocks[v.MaterialVariant] or (v.Name == 'Cobweb' and 129 or 1), pos // BLOCK_SIZE, v)
						end)
					end
				end
			end

			mapLoaded = true
			if not didRemove then
				handlers.entity:addPlayers()
			end

			self.loadthread = nil
		end)
	end
end

function handler:clean()
	for _, v in self.connections do
		v:Disconnect()
	end

	if self.loadthread then
		task.cancel(self.loadthread)
		self.loadthread = nil
	end

	if self.loadconnection then
		self.loadconnection:Disconnect()
		self.loadconnection = nil
	end

	loopClean(self.chunks)
	table.clear(self.connections)
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