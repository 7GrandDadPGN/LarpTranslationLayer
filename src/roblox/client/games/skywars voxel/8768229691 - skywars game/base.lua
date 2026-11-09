local cloneref = cloneref or function(instance)
	return instance
end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local collectionService = cloneref(game:GetService('CollectionService'))
local userSettings = cloneref(UserSettings():GetService('UserGameSettings'))
local textChatService = cloneref(game:GetService('TextChatService'))

local lplr = playersService.LocalPlayer
local skywars, remotes = {}, {}

local tlayer = ...
local handlers = {}
local types = {}

(function()
	local Flamework = require(replicatedStorage['rbxts_include']['node_modules']['@flamework'].core.out).Flamework
	local ControllerTable = {}

	if not debug.getupvalue(Flamework.ignite, 1) then
		repeat task.wait() until debug.getupvalue(Flamework.ignite, 1)
	end

	local function searchFunction(name, i2, v2)
		for i3, v3 in debug.getconstants(v2) do
			if tostring(v3):find('-') == 9 then
				for i = 1, 20 do
					local newIndex = (rawget(remotes, i2) and name..':' or '')..i2..(i ~= 1 and i or '')
					if not remotes[newIndex] then
						remotes[newIndex] = v3
						break
					end
				end
			end
		end
	end

	for i, v in debug.getupvalue(Flamework.ignite, 2).idToObj do
		local name = tostring(v)
		ControllerTable[name] = Flamework.resolveDependency(i)
		for i2, v2 in v do
			if type(v2) == 'function' then
				searchFunction(name, i2, v2)

				for _, v3 in debug.getprotos(v2) do
					searchFunction(name, i2, v3)
				end
			end
		end
	end

	skywars = setmetatable({
		BlockUtil = require(replicatedStorage.TS.util['block-util']).BlockUtil,
		ItemMeta = require(replicatedStorage.TS.item.item).Items,
		Store = require(lplr.PlayerScripts.TS.ui.rodux['global-store']).GlobalStore,
		Remotes = debug.getupvalue(ControllerTable.MeleeController.strikeDesktop, 6),
	}, {
		__index = function(self, ind)
			rawset(self, ind, ControllerTable[ind])
			return rawget(self, ind)
		end
	})
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
		table.clear(skywars)
	end,
	tick = function()
		for _, handler in handlers do
			if handler.tick then
				handler:tick()
			end
		end
	end
}