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

	replicatedStorage.MC.Remotes.Action:FireServer(data)
end

(function()
	tlayer:loadPackets(true)
	unstable = {
		Chat = require(lplr.PlayerScripts.MC.Chat),
		Controller = require(lplr.PlayerScripts.MC.Controller),
		FX = require(lplr.PlayerScripts.MC.FX),
		Menus = require(lplr.PlayerScripts.MC.Menus),
		Net = require(lplr.PlayerScripts.MC.Net),
		Hands = require(lplr.PlayerScripts.MC.Hands),
		World = require(lplr.PlayerScripts.MC.World)
	}

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