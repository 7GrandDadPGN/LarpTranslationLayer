local handler = {
	Name = 'misc',
	connections = {}
}

local COLORS = {Color3.fromRGB(85, 255, 85), Color3.fromRGB(170, 220, 255), Color3.fromRGB(85, 255, 255), Color3.fromRGB(255, 255, 85), Color3.fromRGB(255, 170, 0), Color3.fromRGB(255, 85, 85), Color3.fromRGB(255, 85, 255), Color3.fromRGB(170, 85, 255), Color3.fromRGB(255, 170, 170), Color3.fromRGB(255, 255, 255)}
local function calculateLevelColor(level)
	return COLORS[(math.floor((math.max(1, level) - 1) / 10) % #COLORS) + 1]
end

local function getLevelXp(level)
	level = math.max(level, 1)
	if level >= 1000 then
		return 0
	end

	return math.floor(((((level - 1) ^ 2) * 0.045276) + 32.4) + 0.5)
end

function handler:start()
	self.connections = {
		lplr.OnTeleport:Connect(function()
			if not self.tpflag then
				self.tpflag = true
				tlayer:send('reconnect')
			end
		end),
		lplr:GetAttributeChangedSignal('TotalKills'):Connect(function()
			self:replicateXP()
		end)
	}

	self.oldchat = unstable.Chat.add
	self.oldchatpart = unstable.Chat.addParts
	self.oldsound = unstable.FX.sound

	self:replicateXP()

	local chatfunc
	for _, connection in getconnections(debug.getupvalue(unstable.Chat.close, 4).FocusLost) do
		chatfunc = debug.getupvalue(connection.Function, 4)
		break
	end

	local chathook
	chathook = hookfunction(self.oldchat, function(...)
		local msg, color = ...
		task.spawn(function()
			if type(msg) == 'string' then
				tlayer:send('chat', {
					message = '<font color="#'..(color or Color3.new(1, 1, 1)):ToHex()..'">'..msg..'</font>'
				})
			end
		end)

		return chathook(...)
	end)

	local chathookparts
	chathookparts = hookfunction(self.oldchatpart, function(...)
		local parts = ...
		task.spawn(function()
			local msg = ''
			for _, entry in parts do
				msg ..= '<font color="#'..(entry[2]:ToHex())..'">'..entry[1]..'</font>'
			end

			tlayer:send('chat', {
				message = msg
			})
		end)

		return chathookparts(...)
	end)

	hookfunction(unstable.FX.sound, function() end)

	self.scoreboardthread = task.spawn(function()
		repeat
			self:sendScoreboard()
			task.wait(1)
		until false
	end)

	tlayer.listeners.chat = function(data)
		if data.text == 'reload' then
			handlers.entity:addFirework(40)
			return
		end

		chatfunc(data.text)
		setthreadidentity(8)
	end
end

function handler:replicateXP()
	tlayer:send('experience', {
		experienceBar = 0,
		level = lplr:GetAttribute('TotalKills') or 1,
		totalExperience = 0
	})
end

function handler:sendScoreboard()
	local title = '<font color="#A020F0">Unstable FFA</font>'
	local lines = {}
	local mapTimer = math.max((workspace:GetAttribute('ArenaResetAt') or workspace:GetServerTimeNow()) - workspace:GetServerTimeNow(), 0)

	table.insert(lines, ' ')
	table.insert(lines, 'Kit: <font color="#63ff63">'..(lplr:GetAttribute('Kit') or 'None')..'</font>')
	table.insert(lines, 'Killstreak: <font color="#ff5555">'..(lplr:GetAttribute('Streak') or 0)..'</font>')
	table.insert(lines, 'Next Map: <font color="#00d4f9">'..string.format('%d:%02d', mapTimer // 60, mapTimer % 60)..'</font>')
	table.insert(lines, ' ')
	table.insert(lines, 'Kills: <font color="#ffc933">'..(lplr:GetAttribute('TotalKills') or 0)..'</font>')

	tlayer:send('scoreboard', {
		title = title,
		lines = lines
	})
end

function handler:clean()
	for _, v in self.connections do
		v:Disconnect()
	end

	if self.oldchat then
		restorefunction(self.oldchat)
		self.oldchat = nil
	end

	if self.oldchatpart then
		restorefunction(self.oldchatpart)
		self.oldchatpart = nil
	end

	if self.oldsound then
		restorefunction(self.oldsound)
		self.oldsound = nil
	end

	if self.scoreboardthread then
		task.cancel(self.scoreboardthread)
	end

	table.clear(self.connections)
end

function handler:playLocalSound(sound, pitch)
	local char = handlers.entity.character
	if char and char.pos then
		tlayer:send('play_sound', {
			sound = sound,
			pos = char.pos.Position + Vector3.new(0, 128, 0),
			volume = 2,
			pitch = pitch or 1
		})
	end
end

return handler