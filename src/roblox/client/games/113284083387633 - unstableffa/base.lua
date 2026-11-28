local cloneref = cloneref or function(instance)
	return instance
end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local collectionService = cloneref(game:GetService('CollectionService'))
local textChatService = cloneref(game:GetService('TextChatService'))
local httpService = cloneref(game:GetService('HttpService'))

local lplr = playersService.LocalPlayer
local unstable = {}

local tlayer = ...
local handlers = {}
local types = {}

local function firePacket(data)
	if unstable.Net.tickOf then
		data.k = unstable.Net.tickOf()
		setthreadidentity(8)
	end

	replicatedStorage.GameShared.Remotes.Action:FireServer(data)
end

(function()
	tlayer:loadPackets(true)
	unstable = {
		Chat = require(lplr.PlayerScripts.Client.UI.InGame.Chat),
		Controller = require(lplr.PlayerScripts.Client.Player.Controller),
		FX = require(lplr.PlayerScripts.Client.Effects.FX),
		Menus = require(lplr.PlayerScripts.Client.UI.Screens.Menus),
		Net = require(lplr.PlayerScripts.Client.Core.Net),
		Hands = require(lplr.PlayerScripts.Client.Player.Hands),
		World = require(lplr.PlayerScripts.Client.WorldView.World)
	}

	unstable.ItemTable = debug.getupvalue(require(replicatedStorage.GameShared.Data.Items.Items).def, 2)
	unstable.PitchTable = debug.getupvalue(unstable.World.pitchOf, 1)
end)()

--Types

--Handlers

return {
	start = function()
		for _, handler in handlers do
			handler:start()
		end
	end,
	clean = function()
		for _, handler in handlers do
			pcall(function()
				handler:clean()
			end)
		end
	end,
	disconnect = function()
		table.clear(unstable)
	end,
	tick = function()
		for _, handler in handlers do
			if handler.tick then
				handler:tick()
			end
		end
	end
}