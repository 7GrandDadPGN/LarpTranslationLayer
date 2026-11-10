local handler = {
	Name = 'misc',
	connections = {}
}

function handler:start()
	self.connections = {
		lplr.OnTeleport:Connect(function()
			if not self.tpflag then
				self.tpflag = true
				tlayer:send('reconnect')
			end
		end),
		skywars.GameController.GameEnded:bind(function(data)
			if table.find(data.GameResult.winners, lplr) then
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
					text = '<font color="#FFAA00">VICTORY!</font>',
					fadeIn = 0,
					stay = 0,
					fadeOut = 0
				})
			end
		end)
	}

	setthreadidentity(8)
	self.oldchat = getcallbackvalue(textChatService, 'OnIncomingMessage')
	textChatService.OnIncomingMessage = function(message)
		if message.Status == Enum.TextChatMessageStatus.Success then
			tlayer:send('chat', {
				message = message.PrefixText..' '..message.Text
			})
		end
	end

	local connection = skywars.Store.changed:connect(function(newStore, oldStore)
		if newStore.QueueStartTime ~= oldStore.QueueStartTime then
			if newStore.QueueStartTime ~= 0 then
				self:playLocalSound('portal.portal')
				tlayer:send('chat', {
					message = '\n/c/2Searching for match\n'
				})
			else
				tlayer:send('chat', {
					message = '\n/c/cQueue cancelled.\n'
				})
			end
		end
	end)

	table.insert(self.connections, {Disconnect = function()
		connection:disconnect()
	end})

	self.scoreboardthread = task.spawn(function()
		repeat
			self:sendScoreboard()
			task.wait(1)
		until false
	end)

	tlayer.listeners.chat = function(data)
		textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(data.text)
	end
end

function handler:sendScoreboard()
	local lines = {}
	local state = skywars.Store:getState()
	local diff = math.max(workspace:GetServerTimeNow() - (state.GameStateChangeTime or 0), 0)
	local map = workspace.BlockContainer:FindFirstChild('Map')

	table.insert(lines, '<font color="#AAAAAA">'..DateTime.now():FormatUniversalTime('MM/DD/YY', 'en-us')..'</font>')
	table.insert(lines, ' ')
	table.insert(lines, 'Time played: ')
	table.insert(lines, '<font color="#55FF55">'..(diff // 60)..':'..string.format('%02i', diff % 60)..'</font>')
	table.insert(lines, ' ')
	table.insert(lines, 'Players left: <font color="#55FF55">'..#(state.Players or {})..'</font>')
	table.insert(lines, ' ')
	table.insert(lines, 'Kills: <font color="#55FF55">'..(skywars.HealthController.kills or 0)..'</font>')
	table.insert(lines, ' ')
	table.insert(lines, 'Map: <font color="#55FF55">'..(map and map:GetAttribute('MapName') or 'None')..'</font>')
	table.insert(lines, 'Mode: <font color="#FF5555">Insane</font>')

	tlayer:send('scoreboard', {
		title = '\255e\255lSKYWARS',
		lines = lines
	})
end

function handler:clean()
	for _, v in self.connections do
		v:Disconnect()
	end

	if self.scoreboardthread then
		task.cancel(self.scoreboardthread)
	end

	if self.oldchat then
		textChatService.OnIncomingMessage = self.oldchat
		self.oldchat = nil
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