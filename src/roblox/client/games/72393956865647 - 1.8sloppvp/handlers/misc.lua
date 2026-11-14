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
		lplr:GetAttributeChangedSignal('level'):Connect(function()
			self:replicateXP()
		end),
		lplr:GetAttributeChangedSignal('xp'):Connect(function()
			self:replicateXP()
		end)
	}

	self.oldchat = searchFor(searchFor(slop.ChatController.start, 'initChat'), 'addMessage')
	self.oldkill = debug.getupvalue(slop.EntitySoundRenderer.start, 2)

	local hook
	hook = hookfunction(self.oldchat, function(...)
		local msg, color = ...
		task.spawn(function()
			if type(msg) == 'string' then
				tlayer:send('chat', {
					message = msg
				})
			end
		end)
		return hook(...)
	end)

	local hook2
	hook2 = hookfunction(self.oldkill, function()
		task.spawn(function()
			handler:playLocalSound('random.orb')
			hook2()
		end)
	end)

	self.scoreboardthread = task.spawn(function()
		repeat
			self:sendScoreboard()
			task.wait(1)
		until false
	end)

	tlayer.listeners.chat = function(data)
		if data.text:lower():sub(1, 7) == '/reload' then
			return
		end

		slop.ChatController.submitText(data.text)
		setthreadidentity(8)
		--textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(data.text)
	end
end

function handler:replicateXP()
	local newLevel = lplr:GetAttribute('level') or 1
	if self.level and self.level < newLevel then
		local levelColor = calculateLevelColor(newLevel):ToHex()
		self:playLocalSound('random.levelup')

		tlayer:send('title', {
			action = 2,
			text = '',
			fadeIn = 3,
			stay = 50,
			fadeOut = 7
		})

		tlayer:send('title', {
			action = 0,
			text = string.format('<font color="#%s">LEVEL UP!</font>', levelColor),
			fadeIn = 0,
			stay = 0,
			fadeOut = 0
		})

		tlayer:send('title', {
			action = 1,
			text = string.format('<font color="#AAAAAA">[</font><font color="#%s">%d</font><font color="#AAAAAA">]  \226\134\146  [</font><font color="#%s">%d</font><font color="#AAAAAA">]</font>', calculateLevelColor(self.level):ToHex(), self.level, levelColor, newLevel),
			fadeIn = 0,
			stay = 0,
			fadeOut = 0
		})
	end

	self.level = newLevel
	tlayer:send('experience', {
		experienceBar = math.clamp((lplr:GetAttribute('xp') or 1) / getLevelXp(newLevel), 0, 1),
		level = newLevel,
		totalExperience = lplr:GetAttribute('xp') or 1
	})
end

function handler:sendScoreboard()
	local title = ''
	local lines = {}

	local suc, res = pcall(function()
		local gui = lplr.PlayerGui.Hud.Scoreboard.Container
		local sorted = {}
		for _, entry in gui:GetChildren() do
			if entry:IsA('Frame') then
				table.insert(sorted, entry)
			end
		end

		table.sort(sorted, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)

		for _, line in sorted do
			if line.Name == 'Title' then
				title = line.TextLabel.Text
				continue
			end

			local label = line:FindFirstChild('main')
			table.insert(lines, label and label.Text or ' ')
		end
	end)

	tlayer:send('scoreboard', {
		title = title,
		lines = lines
	})
end

function handler:clean()
	for _, v in self.connections do
		v:Disconnect()
	end

	if self.hook then
		restorefunction(self.hook)
		self.hook = nil
	end

	if self.oldchat then
		restorefunction(self.oldchat)
		self.oldchat = nil
	end

	if self.oldkill then
		restorefunction(self.oldkill)
		self.oldkill = nil
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
			pos = (char.pos.Position / 3) + Vector3.new(0.5, 128, 0.5),
			volume = math.huge,
			pitch = pitch or 1
		})
	end
end

return handler