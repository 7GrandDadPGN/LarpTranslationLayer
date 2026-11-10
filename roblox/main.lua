if not game:IsLoaded() then
	repeat task.wait() until game:IsLoaded()
end

local loadstring = function(...)
	local res, err = loadstring(...)
	if err then
		error('Failed to load : '..err)
	end

	return res
end

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)

	return suc and res ~= nil and res ~= ''
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/LarpTranslationLayer/'..readfile('tlayer/commit.txt')..'/roblox/'..select(1, path:gsub('tlayer/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after tlayer updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local tickloop
local socket
local packetQueue = {}
local tlayer = {
	packets = {client = {}, server = {}},
	listeners = {}
}

local CPackets = {
	arm_animation = (function()
		return function() end
	end)(),
	attack = (function()
		return function(buf)
			return {
				id = buffer.readf64(buf, 1)
			}
		end
	end)(),
	chat = (function()
		return function(buf)
			return {
				text = buffer.readstring(buf, 5, buffer.readu32(buf, 1))
			}
		end
	end)(),
	chunk = (function()
		return function(buf)
			return {
				x = buffer.readi32(buf, 1),
				z = buffer.readi32(buf, 5)
			}
		end
	end)(),
	click_slot = (function()
		return function(buf)
			return {
				windowId = buffer.readu8(buf, 1),
				slot = buffer.readu8(buf, 2),
				action = buffer.readu8(buf, 3),
				mouseButton = buffer.readu8(buf, 4)
			}
		end
	end)(),
	close_window = (function()
		return function() end
	end)(),
	dig = (function()
		return function(buf)
			return {
				status = buffer.readi8(buf, 1),
				pos = Vector3.new(buffer.readi32(buf, 2), buffer.readi32(buf, 6), buffer.readi32(buf, 10)),
				face = buffer.readi8(buf, 14)
			}
		end
	end)(),
	disconnect = (function()
		return function() end
	end)(),
	entity_action = (function()
		return function(buf)
			return {
				action = buffer.readi8(buf, 1)
			}
		end
	end)(),
	login = (function()
		return function() end
	end)(),
	move = (function()
		return function(buf)
			return {
				pos = Vector3.new(buffer.readf64(buf, 1), buffer.readf64(buf, 9), buffer.readf64(buf, 17)),
				yaw = buffer.readf32(buf, 25),
				pitch = buffer.readf32(buf, 29),
				onGround = buffer.readu8(buf, 33) == 1
			}
		end
	end)(),
	place = (function()
		return function(buf)
			return {
				pos = Vector3.new(buffer.readi32(buf, 1), buffer.readi32(buf, 5), buffer.readi32(buf, 9)),
				face = buffer.readi8(buf, 13)
			}
		end
	end)(),
	switch_slot = (function()
		return function(buf)
			return {
				slot = buffer.readu8(buf, 1)
			}
		end
	end)()
}

local SPackets = {
	block_update = (function()
		return function(data)
			local buf = buffer.create(15)
			buffer.writeu16(buf, 1, data.id)
			buffer.writei32(buf, 3, data.pos.X)
			buffer.writei32(buf, 7, data.pos.Y)
			buffer.writei32(buf, 11, data.pos.Z)
			return buf
		end
	end)(),
	chat = (function()
		return function(data)
			local buf = buffer.create(5 + #data.message)
			buffer.writeu32(buf, 1, #data.message)
			buffer.writestring(buf, 5, data.message)
			return buf
		end
	end)(),
	chunk = (function()
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
	end)(),
	combined = (function()
		return function(packets)
			local length = 3
			for _, data in packets do
				length += buffer.len(data) + 2
			end
		
			local buf = buffer.create(length)
			local offset = 3
			buffer.writeu16(buf, 1, #packets)
			for _, data in packets do
				local len = buffer.len(data)
				buffer.writeu16(buf, offset, len)
				buffer.copy(buf, offset + 2, data, 0, len)
				offset += len + 2
			end
		
			return buf
		end
	end)(),
	entity_absorption = (function()
		return function(data)
			local buf = buffer.create(14)
			buffer.writef64(buf, 1, data.id)
			buffer.writef32(buf, 9, data.amount)
			return buf
		end
	end)(),
	entity_animation = (function()
		return function(data)
			local buf = buffer.create(10)
			buffer.writef64(buf, 1, data.id)
			buffer.writeu8(buf, 9, data.animation)
			return buf
		end
	end)(),
	entity_equipment = (function()
		return function(data)
			local buf = buffer.create(15)
			buffer.writef64(buf, 1, data.id)
			buffer.writeu8(buf, 9, data.slot)
		
			if data.item.id ~= 0 then
				buffer.writeu32(buf, 10, data.item.id)
				buffer.writei8(buf, 14, data.item.count)
			end
		
			return buf
		end
	end)(),
	entity_health = (function()
		return function(data)
			local buf = buffer.create(14)
			buffer.writef64(buf, 1, data.id)
			buffer.writef32(buf, 9, data.health)
			return buf
		end
	end)(),
	entity_move = (function()
		return function(data)
			local buf = buffer.create(43)
			buffer.writef64(buf, 1, data.id)
			buffer.writef32(buf, 9, data.yaw)
			buffer.writef32(buf, 13, data.pitch or 0)
			buffer.writeu8(buf, 17, data.onGround and 1 or 0)
			buffer.writef64(buf, 18, data.pos.X)
			buffer.writef64(buf, 26, data.pos.Y)
			buffer.writef64(buf, 34, data.pos.Z)
			return buf
		end
	end)(),
	entity_remove = (function()
		return function(data)
			local buf = buffer.create(9)
			buffer.writef64(buf, 1, data.id)
			return buf
		end
	end)(),
	entity_spawn = (function()
		return function(data)
			local buf = buffer.create(45)
			buffer.writef64(buf, 1, data.id)
			buffer.writeu8(buf, 9, data.type or 1)
			buffer.writeu8(buf, 10, data.lplr and 1 or 0)
			buffer.writeu8(buf, 11, data.bot and 1 or 0)
			buffer.writef32(buf, 12, data.yaw)
			buffer.writef32(buf, 16, data.pitch or 0)
			buffer.writef64(buf, 20, data.pos.X)
			buffer.writef64(buf, 28, data.pos.Y)
			buffer.writef64(buf, 36, data.pos.Z)
			return buf
		end
	end)(),
	entity_state = (function()
		return function(data)
			local buf = buffer.create(11)
			buffer.writef64(buf, 1, data.id)
			buffer.writeu8(buf, 9, data.flag)
			buffer.writeu8(buf, 10, data.state and 1 or 0)
			return buf
		end
	end)(),
	entity_status = (function()
		return function(data)
			local buf = buffer.create(10)
			buffer.writef64(buf, 1, data.id)
			buffer.writeu8(buf, 9, data.status)
			return buf
		end
	end)(),
	experience = (function()
		return function(data)
			local buf = buffer.create(25)
			buffer.writef32(buf, 1, data.experienceBar)
			buffer.writef64(buf, 9, data.level)
			buffer.writef64(buf, 17, data.totalExperience)
			return buf
		end
	end)(),
	login = (function()
		return function(data)
			return buffer.create(1)
		end
	end)(),
	open_window = (function()
		return function(data)
			local buf = buffer.create(6 + #data.name)
			buffer.writeu8(buf, 1, data.windowId)
			buffer.writeu8(buf, 2, data.slots)
			buffer.writeu8(buf, 3, #data.name)
			buffer.writestring(buf, 4, data.name)
			return buf
		end
	end)(),
	play_sound = (function()
		return function(data)
			local offset = #data.sound
			local buf = buffer.create(20 + offset)
			buffer.writeu8(buf, 1, offset)
			buffer.writestring(buf, 2, data.sound)
			buffer.writei32(buf, 3 + offset, data.pos.X * 8)
			buffer.writei32(buf, 7 + offset, data.pos.Y * 8)
			buffer.writei32(buf, 11 + offset, data.pos.Z * 8)
			buffer.writef32(buf, 15 + offset, data.volume or 1)
			buffer.writeu8(buf, 19 + offset, math.clamp((data.pitch or 1) * 63, 0, 255))
			return buf
		end
	end)(),
	reconnect = (function()
		return function(data)
			return buffer.create(1)
		end
	end)(),
	remove_chunk = (function()
		return function(data)
			local buf = buffer.create(9)
			buffer.writei32(buf, 1, data.x)
			buffer.writei32(buf, 5, data.z)
			return buf
		end
	end)(),
	scoreboard = (function()
		local function writeString(buf, offset, str)
			buffer.writeu8(buf, offset, #str)
			buffer.writestring(buf, offset + 1, str)
			return offset + 1 + #str
		end
		
		return function(data)
			local buflen, offset = 3 + #data.title, 2
			for _, line in data.lines do
				buflen += #line + 1
			end
		
			local buf = buffer.create(buflen)
			buffer.writeu8(buf, 1, #data.lines)
		
			for _, line in data.lines do
				offset = writeString(buf, offset, line)
			end
			writeString(buf, offset, data.title)
		
			return buf
		end
	end)(),
	set_slot = (function()
		return function(data)
			local buf = buffer.create(8)
			buffer.writeu8(buf, 1, data.windowId)
			buffer.writeu8(buf, 2, data.slot)
		
			if data.item.id ~= 0 then
				buffer.writeu16(buf, 3, data.item.id)
				buffer.writei8(buf, 7, data.item.count)
			end
		
			return buf
		end
	end)(),
	tablist = (function()
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
	end)(),
	teleport = (function()
		return function(data)
			local buf = buffer.create(25)
			buffer.writef64(buf, 1, data.pos.X)
			buffer.writef64(buf, 9, data.pos.Y)
			buffer.writef64(buf, 17, data.pos.Z)
			return buf
		end
	end)(),
	title = (function()
		local function writeString(buf, offset, str)
			buffer.writeu8(buf, offset, #str)
			buffer.writestring(buf, offset + 1, str)
			return offset + 1 + #str
		end
		
		return function(data)
			local offset = 2
			local buf = buffer.create(16 + #data.text)
			buffer.writeu8(buf, 1, data.action)
			offset = writeString(buf, offset, data.text)
			buffer.writei32(buf, offset, data.fadeIn)
			buffer.writei32(buf, offset + 4, data.stay)
			buffer.writei32(buf, offset + 8, data.fadeOut)
		
			return buf
		end
	end)(),
	window_items = (function()
		return function(data)
			local buf = buffer.create(3 + (#data.slots * 5))
			buffer.writeu8(buf, 1, data.windowId)
			buffer.writeu8(buf, 2, #data.slots)
		
			for index, item in data.slots do
				if item.id ~= 0 then
					buffer.writeu32(buf, 3 + (index * 5), item.id)
					buffer.writei8(buf, 7 + (index * 5), item.count)
				end
			end
		
			return buf
		end
	end)()
}

function tlayer:init()
	if shared.tlayer then
		shared.tlayer:disconnect()
		shared.tlayer = nil
	end

	pcall(function()
		for _, connection in getconnections(game:GetService('Players').LocalPlayer.Idled) do
			connection:Disable()
		end
	end)

	self:map(CPackets, false)
	self:map(SPackets, true)

	if isfile('tlayer/games/'..game.PlaceId..'.lua') then
		self.game = loadstring(readfile('tlayer/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(self)
	else
		if not shared.VapeDeveloper then
			local success, data = pcall(downloadFile, 'tlayer/games/'..game.PlaceId..'.lua')
			if success then
				self.game = loadstring(data, tostring(game.PlaceId))(self)
			end
		end
	end

	if not self.game then
		return
	end

	self.listeners.login = function()
		self:login()
	end

	self.listeners.disconnect = function()
		if tickloop then
			task.cancel(tickloop)
			tickloop = nil
		end

		if self.game then
			self.game:clean()
		end
	end

	shared.tlayer = self
	self:connect()
end

function tlayer:login()
	if self.game then
		self.game:start()

		tickloop = task.spawn(function()
			repeat
				self.game:tick()

				if #packetQueue > 1 then
					socket:Send(buffer.tostring(self.packets.server.combined(packetQueue)), true)
				elseif packetQueue[1] then
					socket:Send(buffer.tostring(packetQueue[1]), true)
				end

				table.clear(packetQueue)
				task.wait(0.016)
			until false
		end)
	end
end

function tlayer:connect()
	socket = WebSocket.connect('ws://'..(shared.tlayerip or 'localhost')..':6874')
	socket:Send(buffer.tostring(self.packets.server.login()), true)

	socket.OnMessage:Connect(function(data)
		data = buffer.fromstring(data)

		local packet = self.packets.client[buffer.readu8(data, 0)]
		if packet and self.listeners[packet[1]] then
			self.listeners[packet[1]](packet[2](data))
		end
	end)

	socket.OnClose:Connect(function()
		socket = nil
		if self.disconnect then
			self:disconnect()
		end
	end)
end

function tlayer:disconnect()
	self.disconnect = nil

	if socket then
		socket:Close()
		socket.OnClose:Wait()
		socket = nil
	end

	if tickloop then
		task.cancel(tickloop)
		tickloop = nil
	end

	if self.game then
		self.game:clean()
		self.game:disconnect()
	end

	table.clear(self.listeners)
	table.clear(self)
	shared.tlayer = nil
end

function tlayer:map(packetList, isServer)
	local sorted = {}
	for id in packetList do
		table.insert(sorted, id)
	end
	table.sort(sorted)

	if isServer then
		self.packets.server = {}

		for i, v in sorted do
			i = i - 1
			local original = packetList[v]
			self.packets.server[v] = function(...)
				local packet = original(...)
				buffer.writeu8(packet, 0, i)
				return packet
			end
		end
	else
		self.packets.client = {}
		for i, v in sorted do
			self.packets.client[i - 1] = {v, packetList[v]}
		end
	end

	table.clear(packetList)
end

function tlayer:send(id, ...)
	local packet = self.packets.server[id]
	if packet and socket then
		table.insert(packetQueue, packet(...))
	end
end

tlayer:init()