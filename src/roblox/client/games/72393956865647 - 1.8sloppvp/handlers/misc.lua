local handler = {
	Name = 'misc',
	connections = {}
}

local COLORS = {Color3.fromRGB(85, 255, 85), Color3.fromRGB(170, 220, 255), Color3.fromRGB(85, 255, 255), Color3.fromRGB(255, 255, 85), Color3.fromRGB(255, 170, 0), Color3.fromRGB(255, 85, 85), Color3.fromRGB(255, 85, 255), Color3.fromRGB(170, 85, 255), Color3.fromRGB(255, 170, 170), Color3.fromRGB(255, 255, 255)}
local function calculateLevelColor(level)
	return COLORS[(math.floor((math.max(1, level) - 1) / 10) % #COLORS) + 1]
end

local function xpForLevel(xp)
	local multi = math.max(1, math.floor(xp))
	return ((100 / 2) * multi) * (multi - 1)
end

function handler:start()
	self.connections = {
		lplr.OnTeleport:Connect(function()
			if not self.tpflag then
				self.tpflag = true
				tlayer:send('reconnect')
			end
		end),
	}

	self.oldchat = debug.getupvalue(debug.getupvalue(slop.ChatController.start, 21), 20)
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

	--[[self.oldchat = getcallbackvalue(textChatService, 'OnIncomingMessage')
	textChatService.OnIncomingMessage = function(message)
		if message.Status == Enum.TextChatMessageStatus.Success then
			local prefix = message.PrefixText
			local plr = message.TextSource and playersService:GetPlayerByUserId(message.TextSource.UserId)
			if plr then
				prefix = '<font color="#AAAAAA">[</font><font color="#'..calculateLevelColor(plr:GetAttribute('AccountLevel') or 0):ToHex()..'">'..(plr:GetAttribute('AccountLevel') or 0)..'</font><font color="#AAAAAA">] </font><font color="#'..(plr:GetAttribute('NameColor') and plr:GetAttribute('NameColor'):ToHex() or 'AAAAAA')..'">'..(plr.DisplayName or plr.Name)..'</font>:'
			end

			tlayer:send('chat', {
				message = prefix..' '..message.Text
			})
		end
	end]]

	--[[tlayer:send('experience', {
		experienceBar = lplr:GetAttribute('XPProgress') or 0,
		level = lplr:GetAttribute('XPLevel') or 1,
		totalExperience = lplr:GetAttribute('TotalXP') or 0
	})]]

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