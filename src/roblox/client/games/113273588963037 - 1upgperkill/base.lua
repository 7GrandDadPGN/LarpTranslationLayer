local cloneref = cloneref or function(instance)
	return instance
end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local collectionService = cloneref(game:GetService('CollectionService'))
local textChatService = cloneref(game:GetService('TextChatService'))

local lplr = playersService.LocalPlayer
local upg = {}

local tlayer = ...
local handlers = {}
local types = {}

(function()
	upg = {
		ClientState = require(lplr.PlayerScripts.Client.Core.ClientState),
		CombatController = require(lplr.PlayerScripts.Client.Controllers.CombatController),
		CameraController = require(lplr.PlayerScripts.Client.Controllers.CameraController),
		MovementController = require(lplr.PlayerScripts.Client.Controllers.MovementController),
		Input = require(lplr.PlayerScripts.Client.Controllers.Input),
		InventoryController = require(lplr.PlayerScripts.Client.Controllers.InventoryController),
		RemoteSync = require(lplr.PlayerScripts.Client.Controllers.RemoteSync)
	}

	upg.DoAction = debug.getupvalue(upg.InventoryController.init, 6)
	upg.InputTable = debug.getupvalue(upg.Input.isDown, 7)
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
		table.clear(upg)
	end,
	tick = function()
		for _, handler in handlers do
			if handler.tick then
				handler:tick()
			end
		end
	end
}