local handler = {
	Name = 'tablist',
	connections = {}
}

function handler:start()
	self:sendTablist()
	self.connections = {
		playersService.PlayerAdded:Connect(function(plr)
			self:sendTablist()
		end),
		playersService.PlayerRemoving:Connect(function()
			self:sendTablist()
		end)
	}
end

function handler:sendTablist()
	local data = {}
	for _, plr in playersService:GetPlayers() do
		table.insert(data, {
			Name = plr.Name,
			UserId = plr.UserId,
			isLocal = plr == lplr,
			Prefix = '<font color="#AAAAAA">]</font><font color="#AAAAAA"> </font>',
			Suffix = ''
		})
	end

	setthreadidentity(8)
	tlayer:send('tablist', data)
end

function handler:clean()
	for _, v in self.connections do
		v:Disconnect()
	end

	table.clear(self.connections)
end

return handler