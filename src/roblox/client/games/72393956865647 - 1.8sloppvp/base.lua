local cloneref = cloneref or function(instance)
	return instance
end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local collectionService = cloneref(game:GetService('CollectionService'))
local textChatService = cloneref(game:GetService('TextChatService'))

local lplr = playersService.LocalPlayer
local slop = {}

local tlayer = ...
local handlers = {}
local types = {}

local function searchFor(func, name)
	for i, v in debug.getupvalues(func) do
		if type(v) == 'function' and debug.info(v, 'n') == name then
			return v, i
		end
	end
end

(function()
	tlayer:loadPackets(false)
	slop = {
		ChatController = require(replicatedStorage.Client.Controller_5.ChatController),
		CombatController = require(replicatedStorage.Client.Controller_5.CombatController_5),
		CameraController = require(replicatedStorage.Client.Controller_5.CameraController),
		CharacterAnimator = require(replicatedStorage.Client.Controller_5.CharacterAnimator),
		CharacterController = require(replicatedStorage.Client.Controller_5.CharacterController),
		InventoryController = require(replicatedStorage.Client.Controller_5.InventoryController),
		InputHistoryController = require(replicatedStorage.Client.Controller_5.InputHistoryController_5),
		ItemLookup = require(replicatedStorage.Shared.ItemLookup),
		ItemUseController = require(replicatedStorage.Client.Controller_5.ItemUseController),
		EntityRenderer = require(replicatedStorage.Client.Controller_5.EntityRenderer),
		EntitySoundRenderer = require(replicatedStorage.Client.Controller_5.EntitySoundRenderer),
		MovementController = require(replicatedStorage.Client.Controller_5.MovementController_5),
		ViewmodelController = require(replicatedStorage.Client.Controller_5.ViewmodelController),
	}
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
		table.clear(slop)
	end,
	tick = function()
		for _, handler in handlers do
			if handler.tick then
				handler:tick()
			end
		end
	end
}