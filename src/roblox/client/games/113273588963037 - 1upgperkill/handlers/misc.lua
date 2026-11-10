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
		upg.ClientState.ProfileChanged:Connect(function()
			task.spawn(function()
				if upg.ClientState.profile then
					local oldlevelxp = xpForLevel(upg.ClientState.profile.levelRewarded or 0)
					tlayer:send('experience', {
						experienceBar = math.clamp((upg.ClientState.profile.xp - oldlevelxp) / (xpForLevel((upg.ClientState.profile.levelRewarded or 0) + 1) - oldlevelxp), 0, 1),
						level = upg.ClientState.profile.levelRewarded or 0,
						totalExperience = upg.ClientState.profile.xp or 0
					})

					self:sendScoreboard()
				end
			end)
		end),
		upg.ClientState.UpgradeChanged:Connect(function()
			task.spawn(function()
				if upg.ClientState.upgrade then
					self:sendScoreboard()
				end
			end)
		end),
		upg.ClientState.Notified:Connect(function(data)
			task.spawn(function()
				if data.kind == 'broadcast' then
					local isSelf = data.id == (lplr.Character and lplr.Character:GetAttribute('CombatantId') or -math.huge)

					if data.event == 'runWon' then
						if isSelf then
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
								text = '<font color="#FFAA00">RUN COMPLETE!</font>',
								fadeIn = 0,
								stay = 0,
								fadeOut = 0
							})
						end
					end
				end

				if type(data.text) == 'string' then
					tlayer:send('chat', {
						message = '<font color="#'..(data.text == 'PvP enabled!' and 'FF5555' or 'FFAA00')..'">'..data.text..'</font>'
					})
				end
			end)
		end),
		replicatedStorage.Remotes.KillFeed.OnClientEvent:Connect(function(data)
			if type(data) == 'table' and data.killerId == (lplr.Character and lplr.Character:GetAttribute('CombatantId') or -math.huge) then
				self:playLocalSound('random.orb')
			end

			local msg = data.killMessage and data.killMessage ~= '' and data.killMessage or 'killed'
			tlayer:send('chat', {
				message = data.killer and `<font color="#ff5555">{data.killer} {msg} {data.victim}.</font>` or `<font color="#ff5555">{data.victim} died.</font>`
			})
		end)
	}

	self.oldchat = getcallbackvalue(textChatService, 'OnIncomingMessage')
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
	end

	if upg.ClientState.profile then
		local oldlevelxp = xpForLevel(upg.ClientState.profile.levelRewarded or 0)
		tlayer:send('experience', {
			experienceBar = math.clamp((upg.ClientState.profile.xp - oldlevelxp) / (xpForLevel((upg.ClientState.profile.levelRewarded or 0) + 1) - oldlevelxp), 0, 1),
			level = upg.ClientState.profile.levelRewarded or 0,
			totalExperience = upg.ClientState.profile.xp or 0
		})
	end

	self:sendScoreboard()

	--[[tlayer:send('experience', {
		experienceBar = lplr:GetAttribute('XPProgress') or 0,
		level = lplr:GetAttribute('XPLevel') or 1,
		totalExperience = lplr:GetAttribute('TotalXP') or 0
	})]]

	--[[self.scoreboardthread = task.spawn(function()
		repeat
			self:sendScoreboard()
			task.wait(1)
		until false
	end)]]

	tlayer.listeners.chat = function(data)
		if data.text:lower():sub(1, 7) == '/reload' then
			return
		end

		textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(data.text)
	end
end

function handler:sendScoreboard()
	local lines = {}
	local upgrade = upg.ClientState.upgrade
	table.insert(lines, ' ')

	if upgrade then
		table.insert(lines, 'Upgrade: <font color="#'..(upgrade.phase == 'maxed' and 'FF5555' or '55FF55')..'">'..(upgrade.phase == 'maxed' and (not ((upgrade.stars or 0) > 0) and 'Maxed' or ('Maxed +%*'):format(upgrade.stars)) or ('%*/%*'):format(upgrade.index, upgrade.total))..'</font>')
		table.insert(lines, 'Streak: <font color="#55FF55">'..(upgrade.streak or 0)..'</font>')
	end

	table.insert(lines, ' ')
	if upg.ClientState.profile then
		table.insert(lines, 'Gold: <font color="#FFAA00">'..(upg.ClientState.profile.coins or 0)..'g</font>')
		table.insert(lines, 'Emeralds: <font color="#55FF55">'..(upg.ClientState.profile.emeralds or 0)..'</font>')
		table.insert(lines, 'Level: <font color="#55FF55">'..(upg.ClientState.profile.levelRewarded or 0)..'</font>')
	end

	tlayer:send('scoreboard', {
		title = '\255e\255lUPG PER KILL',
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
		textChatService.OnIncomingMessage = self.oldchat
		self.oldchat = nil
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