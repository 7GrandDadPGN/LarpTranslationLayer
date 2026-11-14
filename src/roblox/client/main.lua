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
local kickConnection
local socket
local packetQueue = {}
local packetThread
local tlayer = {
	packets = {client = {}, server = {}},
	listeners = {}
}

local CPackets = {
--CPackets
}

local SPackets = {
--SPackets
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

		kickConnection = game:GetService('GuiService').UiMessageChanged:Connect(function(msgType, newMessage)
			if game:GetService('GuiService'):GetErrorType().Name:find('Disconnect') then
				self:send('kick', {
					message = newMessage
				})
			end
		end)

		tickloop = task.spawn(function()
			repeat
				self.game:tick()
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

	if packetThread then
		task.cancel(packetThread)
		packetThread = nil
	end

	if kickConnection then
		kickConnection:Disconnect()
		kickConnection = nil
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

		if not packetThread then
			packetThread = task.defer(function()
				if #packetQueue > 1 then
					socket:Send(buffer.tostring(self.packets.server.combined(packetQueue)), true)
				elseif packetQueue[1] then
					socket:Send(buffer.tostring(packetQueue[1]), true)
				end

				table.clear(packetQueue)
				packetThread = nil
			end)
		end
	end
end

tlayer:init()