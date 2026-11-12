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

(function()
	slop = {
		ChatController = require(replicatedStorage.Client.Controller_1.ChatController),
		CombatController = require(replicatedStorage.Client.Controller_1.CombatController_1),
		CameraController = require(replicatedStorage.Client.Controller_1.CameraController),
		CharacterAnimator = require(replicatedStorage.Client.Controller_1.CharacterAnimator),
		CharacterController = require(replicatedStorage.Client.Controller_1.CharacterController),
		InventoryController = require(replicatedStorage.Client.Controller_1.InventoryController),
		InputHistoryController = require(replicatedStorage.Client.Controller_1.InputHistoryController_1),
		ItemLookup = require(replicatedStorage.Shared.ItemLookup),
		ItemUseController = require(replicatedStorage.Client.Controller_1.ItemUseController),
		EntityRenderer = require(replicatedStorage.Client.Controller_1.EntityRenderer),
		EntitySoundRenderer = require(replicatedStorage.Client.Controller_1.EntitySoundRenderer),
		MovementController = require(replicatedStorage.Client.Controller_1.MovementController_1),
		ViewmodelController = require(replicatedStorage.Client.Controller_1.ViewmodelController),
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