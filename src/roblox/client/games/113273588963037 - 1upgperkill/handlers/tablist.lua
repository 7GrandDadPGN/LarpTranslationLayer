local handler = {
	Name = 'tablist',
	connections = {}
}

local COLORS = {Color3.fromRGB(85, 255, 85), Color3.fromRGB(170, 220, 255), Color3.fromRGB(85, 255, 255), Color3.fromRGB(255, 255, 85), Color3.fromRGB(255, 170, 0), Color3.fromRGB(255, 85, 85), Color3.fromRGB(255, 85, 255), Color3.fromRGB(170, 85, 255), Color3.fromRGB(255, 170, 170), Color3.fromRGB(255, 255, 255)}
local function calculateLevelColor(level)
	return COLORS[(math.floor((math.max(1, level) - 1) / 10) % #COLORS) + 1]
end

function handler:start()
	self:sendTablist()
	self.connections = {
		playersService.PlayerAdded:Connect(function(plr)
			self:sendTablist()

			for _, attr in {'AccountLevel', 'NameColor'} do
				table.insert(self.connections, plr:GetAttributeChangedSignal(attr):Connect(function()
					self:sendTablist()
				end))
			end
		end),
		playersService.PlayerRemoving:Connect(function()
			self:sendTablist()
		end)
	}

	for _, plr in playersService:GetPlayers() do
		for _, attr in {'AccountLevel', 'NameColor'} do
			table.insert(self.connections, plr:GetAttributeChangedSignal(attr):Connect(function()
				self:sendTablist()
			end))
		end
	end
end

function handler:sendTablist()
	local data = {}
	for _, plr in playersService:GetPlayers() do
		table.insert(data, {
			Name = plr.Name,
			UserId = plr.UserId,
			isLocal = plr == lplr,
			Prefix = '<font color="#AAAAAA">[</font><font color="#'..calculateLevelColor(plr:GetAttribute('AccountLevel') or 0):ToHex()..'">'..(plr:GetAttribute('AccountLevel') or 0)..'</font><font color="#AAAAAA">]</font><font color="#'..(plr:GetAttribute('NameColor') and plr:GetAttribute('NameColor'):ToHex() or 'AAAAAA')..'"> </font>',
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