local handler = {
	Name = 'tablist',
	connections = {}
}

function handler:start()
	self:sendTablist()
	self.connections = {
		playersService.PlayerAdded:Connect(function(plr)
			self:sendTablist()
			table.insert(self.connections, plr:GetAttributeChangedSignal('TeamId'):Connect(function()
				self:sendTablist()
			end))
		end),
		playersService.PlayerRemoving:Connect(function()
			self:sendTablist()
		end)
	}

	for _, plr in playersService:GetPlayers() do
		table.insert(self.connections, plr:GetAttributeChangedSignal('TeamId'):Connect(function()
			self:sendTablist()
		end))
	end
end

function handler:sendTablist()
	local data = {}
	for _, plr in playersService:GetPlayers() do
		table.insert(data, {
			Name = plr.Name,
			UserId = plr.UserId,
			isLocal = plr == lplr,
			Prefix = lplr:GetAttribute('TeamId') ~= plr:GetAttribute('TeamId') and '/c/c' or '/c/a',
			Suffix = ''
		})
	end

	tlayer:send('tablist', data)
end

function handler:clean()
	for _, v in self.connections do
		v:Disconnect()
	end

	table.clear(self.connections)
end

return handler