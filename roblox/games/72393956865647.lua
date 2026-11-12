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

types.blocks = (function()
	return {
		acacia_leaves = 161,
		andesite = {1, 5},
		anvil = 145,
		azalea_leaves = 161,
		azure_bluet = {38, 1},
		barrel = 5,
		birch_leaves = {18, 2},
		birch_log = {17, 2},
		black_concrete = {159, 15},
		blue_concerete = {159, 11},
		bookshelf = 47,
		bricks = 45,
		brown_concrete = {159, 12},
		brown_mushroom = 39,
		brown_mushroom_block = 99,
		cactus = 81,
		campfire = 5,
		cauldron = 380,
		chest = {54, 5},
		chiseled_stone_bricks = {98, 3},
		coal_ore = 16,
		coarse_dirt = {3, 1},
		cobblestone = 4,
		cobweb = 30,
		cornflower = 37,
		crafting_table = 58,
		cyan_concrete = {159, 9},
		dandelion = 37,
		dark_oak_log = {162, 1},
		dark_oak_planks = {5, 5},
		dark_oak_fence = 191,
		diorite = {1, 3},
		dirt = 3,
		dirt_path = {3, 2},
		dispenser = 23,
		emerald_block = 133,
		end_stone = 121,
		end_stone_bricks = 121,
		ender_chest = {130, 5},
		furnace = 61,
		glass = 20,
		glass_pane = 102,
		glowstone = 89,
		gold_block = 41,
		granite = {1, 1},
		grass_block = 2,
		gravel = 13,
		gray_concrete = {159, 7},
		green_concrete = {159, 13},
		hay_block = 170,
		hopper = 154,
		ice = 79,
		iron_block = 42,
		iron_ore = 15,
		jukebox = 84,
		jungle_log = {17, 3},
		lava = 11,
		leaf_litter = {31, 2},
		light_blue_concrete = {159, 3},
		light_gray_concrete = {159, 8},
		lime_concrete = {159, 5},
		mossy_cobblestone = 48,
		nether_bricks = 112,
		oak_leaves = 18,
		oak_log = 17,
		oak_planks = 5,
		oak_fence = 85,
		oak_wood = 17,
		obsidian = 49,
		orange_concrete = {159, 1},
		orange_wool = {35, 1},
		oxeye_daisy = {38, 8},
		packed_ice = 174,
		pink_concrete = {159, 6},
		podzol = {3, 2},
		polished_granite = {1, 2},
		poppy = 38,
		pumpkin = 86,
		purple_concrete = {159, 10},
		quartz_block = 155,
		red_wool = {35, 14},
		sand = 12,
		sandstone = 24,
		short_grass = {31, 1},
		slime_block = 165,
		smooth_stone = 1,
		snow_block = 80,
		spruce_log = {17, 1},
		spruce_planks = {5, 1},
		spruce_fence = 188,
		stone = 1,
		stone_bricks = 98,
		tall_grass = {175, 2},
		tnt = 46,
		trapped_chest = 146,
		white_concrete = 159,
		white_wool = 35,
		yellow_concrete = {159, 4},
		yellow_wool = {35, 4},
		water = 9,
	}
end)()

types.itemlimits = (function()
	return {}
end)()

types.items = (function()
	local data = {
		angel_feather = 288,
		arrow = 262,
		bow = 261,
		chainmail_boots = 305,
		chainmail_chestplate = 303,
		chainmail_helmet = 302,
		chainmail_leggings = 304,
		creeper_gunpowder = 289,
		diamond_axe = 279,
		diamond_boots = 313,
		diamond_chestplate = 311,
		diamond_helmet = 310,
		diamond_leggings = 312,
		diamond_shove = 277,
		diamond_sword = 276,
		ender_pearl = 368,
		fire_aspect_iron_sword = 267,
		fishing_rod = 346,
		golden_apple = 322,
		golden_axe = 286,
		golden_boots = 317,
		golden_chestplate = 315,
		golden_helmet = 314,
		golden_leggings = 316,
		golden_sword = 283,
		iron_axe = 258,
		iron_boots = 309,
		iron_chestplate = 307,
		iron_helmet = 306,
		iron_leggings = 308,
		iron_sword = 267,
		knockback_stick = 280,
		leather_boots = 301,
		leather_chestplate = 299,
		leather_helmet = 298,
		leather_leggings = 300,
		netherite_axe = 279,
		netherite_boots = 313,
		netherite_chestplate = 311,
		netherite_helmet = 310,
		netherite_leggings = 312,
		netherite_sword = 276,
		oak_boat = 333,
		power_bow = 261,
		sharpness_golden_sword = 283,
		snowball = 332,
		stone_axe = 275,
		stone_sword = 272,
		wooden_axe = 271,
		wooden_sword = 268
	}
	
	for i, v in types.blocks do
		data[i] = v
	end
	
	return data
end)()

handlers.entity = (function()
	local BLOCK_SIZE = 3
	
	local handler = {
		Name = 'entity',
		entities = {},
		threads = {},
		threads2 = {},
		hooks = {},
		connections = {},
		aimC0 = CFrame.new(),
		botId = -1,
		sneaking = false,
		sprinting = false,
		spawned = false
	}
	
	local function customHook(func, replacement)
		if not table.find(handler.hooks, func) then
			table.insert(handler.hooks, func)
			return hookfunction(func, replacement)
		end
	end
	
	local function decodeHurtList(arg)
		local hurt = {}
		if type(arg) == 'buffer' then
			for i = 0, buffer.len(arg) - 5, 5 do
				table.insert(hurt, {
					id = buffer.readu32(arg, i),
					isFire = bit32.band(buffer.readu8(arg, i + 4), 1) > 0
				})
			end
		end
	
		return hurt
	end
	
	local function decodeStatusList(arg)
		local data = {}
		if type(arg) ~= 'buffer' then
			return data
		end
	
		local len = buffer.len(arg)
		local offset = 0
		while offset + 9 <= len do
			local flags = buffer.readu8(arg, offset + 8)
			local entry = {
				id = buffer.readu32(arg, offset),
				health = buffer.readf32(arg, offset + 4),
				isInvisible = bit32.band(flags, 2) > 0,
				isVanished = bit32.band(flags, 8) > 0,
				isOnFire = bit32.band(flags, 1) > 0,
				isHidden = bit32.band(flags, 4) > 0
			}
	
			offset = offset + 9
			if bit32.band(flags, 16) <= 0 then
				table.insert(data, entry)
				continue
			end
	
			if len < offset + 3 then
				break
			else
				entry.effectColor = Color3.fromRGB(buffer.readu8(arg, offset), buffer.readu8(arg, offset + 1), buffer.readu8(arg, offset + 2))
				offset = offset + 3
				table.insert(data, entry)
			end
		end
	
		return data
	end
	
	function handler:start()
		local tickFunc = debug.getupvalue(debug.getupvalue(slop.MovementController.start, 14), 5)
		local entities = debug.getupvalue(debug.getupvalue(slop.EntityRenderer.start, 2), 10)
		local localState = debug.getupvalue(tickFunc, 7)
		local attack = debug.getupvalue(debug.getupvalue(slop.CombatController.attackAtScreenPoint_1, 2), 9)
		local clickFunc = debug.getupvalue(slop.InputHistoryController.init, 2)
	
		self.oldtick = tickFunc
		self.old = debug.getupvalue(tickFunc, 28)
	
		debug.setupvalue(debug.getupvalue(slop.MovementController.start, 14), 5, function() end)
		debug.setupvalue(tickFunc, 28, {
			simulateTick = function(state)
				local entity = handler.character
	
				if entity and entity.pos then
					state.position = entity.pos.Position / 3
					state.previousPosition = state.position
					state.velocity = entity.velocity / 3
					state.isOnGround = entity.onGround
					state.isSprinting = handler.sprinting or false
					state.isSneakHeld = handler.sneaking or false
				end
			end
		})
	
		local correct
		correct = customHook(debug.getupvalue(slop.MovementController.start, 8), function(...)
			local pos = select(2, ...)
			task.spawn(function()
				if typeof(pos) == 'Vector3' then
					tlayer:send('teleport', {
						pos = self:convertPosition(pos, self.character, true)
					})
				end
			end)
			return correct(...)
		end)
	
		local move
		move = customHook(debug.getupvalue(debug.getupvalue(slop.EntityRenderer.start, 2), 11), function(...)
			local res = table.pack(move(...))
			local arg = ...
			task.spawn(function()
				local entity = handler:getEntity(arg.id)
				if entity then
					if entity.isSneaking ~= arg.isSneaking then
						entity.isSneaking = arg.isSneaking
						tlayer:send('entity_state', {
							id = entity.Id,
							flag = 1,
							state = entity.isSneaking
						})
					end
	
					tlayer:send('entity_move', {
						id = entity.Id,
						yaw = (math.deg(arg.yaw * -1) - 180) % 360,
						pitch = math.deg(arg.pitch * -1) % 360,
						pos = self:convertPosition(arg.position, entity, true),
						onGround = false
					})
				end
			end)
	
			return unpack(res, 1, res.n)
		end)
	
		local add
		add = customHook(debug.getupvalue(debug.getupvalue(slop.EntityRenderer.start, 2), 12), function(...)
			local res = table.pack(add(...))
			local arg = ...
			task.spawn(function()
				if res[1] then
					handler:addEntity(res[1])
				end
			end)
	
			return unpack(res, 1, res.n)
		end)
	
		local remove
		remove = customHook(debug.getupvalue(debug.getupvalue(slop.EntityRenderer.start, 2), 15), function(...)
			local res = table.pack(remove(...))
			local arg = ...
			task.spawn(function()
				handler:removeEntity(arg.id)
			end)
	
			return unpack(res, 1, res.n)
		end)
	
		local states
		states = customHook(debug.getupvalue(slop.EntityRenderer.start, 2), function(...)
			local res = table.pack(states(...))
			local arg = ...
			task.spawn(function()
				if type(arg) == 'table' then
					for _, data in arg do
						if data.player == lplr then
							handler.character.CId = data.id
						end
					end
				end
			end)
	
			return unpack(res, 1, res.n)
		end)
	
		local states
		states = customHook(debug.getupvalue(slop.EntityRenderer.start, 4), function(...)
			local arg = ...
			task.spawn(function()
				for _, data in decodeStatusList(arg) do
					local entity = handler:getEntity(data.id)
					if entity and entity ~= self.character then
						if data.health ~= entity.Health then
							entity.Health = data.health
							tlayer:send('entity_health', {
								id = entity.Id,
								health = entity.Health
							})
						end
	
						if data.isOnFire ~= entity.isOnFire then
							entity.isOnFire = data.isOnFire
							tlayer:send('entity_state', {
								id = entity.Id,
								flag = 0,
								state = entity.isOnFire
							})
						end
					end
				end
			end)
	
			return states(...)
		end)
	
		local hurt
		hurt = customHook(debug.getupvalue(slop.EntityRenderer.start, 5), function(...)
			local arg = ...
			task.spawn(function()
				local hurtList = decodeHurtList(arg)
				for _, entry in hurtList do
					local entity = handler:getEntity(entry.id)
					if entity then
						tlayer:send('entity_status', {
							id = entity.Id,
							status = 2
						})
	
						tlayer:send('play_sound', {
							sound = 'game.player.hurt',
							pos = self:convertPosition(entity.State.position, entity, true),
							volume = 1,
							pitch = (math.random() - math.random()) * 0.2 + 1
						})
					end
				end
			end)
	
			return hurt(...)
		end)
	
		local criticalHook
		criticalHook = customHook(debug.getupvalue(slop.EntityRenderer.start, 6), function(...)
			local arg = ...
			task.spawn(function()
				local entity = handler:getEntity(arg)
				if entity then
					tlayer:send('entity_animation', {
						id = entity.Id,
						animation = 4
					})
				end
			end)
	
			return criticalHook(...)
		end)
	
		local swingHook
		swingHook = customHook(debug.getupvalue(slop.CharacterAnimator.start, 2), function(...)
			local arg = ...
			task.spawn(function()
				local entity = handler:getEntity(arg)
				if entity and entity ~= self.character then
					tlayer:send('entity_animation', {
						id = entity.Id,
						animation = 0
					})
				end
			end)
	
			return swingHook(...)
		end)
	
		local hurtHook
		hurtHook = customHook(debug.getupvalue(slop.CharacterController.start, 9), function(...)
			task.spawn(function()
				local entity = handler:getEntity(arg)
				if self.character then
					tlayer:send('entity_status', {
						id = self.character.Id,
						status = 2
					})
				end
			end)
	
			return hurtHook(...)
		end)
	
		local healthHook
		local function updateHealth(...)
			local hp = ...
			task.spawn(function()
				if type(hp) == 'number' and self.character then
					if hp <= 0 then
						self.character.dead = true
					elseif self.character.dead then
						self:removeEntity(self.character.CId)
						self:addEntity({
							yaw = 0,
							pitch = 0,
							health = hp,
							id = debug.getupvalue(slop.EntityRenderer.getLocalEntityId, 1),
							position = localState.position,
							player = lplr
						})
	
						self.character.dead = false
						return
					end
	
					tlayer:send('entity_health', {
						id = self.character.Id,
						health = hp
					})
				end
			end)
	
			return healthHook(...)
		end
	
		healthHook = customHook(debug.getupvalue(slop.CharacterController.start, 10), function(...)
			return updateHealth(...)
		end)
	
		self:addEntity({
			yaw = 0,
			pitch = 0,
			health = debug.getupvalue(healthHook, 1),
			id = debug.getupvalue(slop.EntityRenderer.getLocalEntityId, 1),
			position = localState.position,
			player = lplr
		})
	
		for _, entity in entities do
			self:addEntity(entity)
		end
	
		tlayer.listeners.move = function(data)
			local entity = self.character
			if entity then
				data.pos = self:convertPosition(data.pos, entity, false)
				local newCF = CFrame.new(data.pos) * CFrame.Angles(0, math.rad((data.yaw * -1) - 180), 0)
	
				self.aimC0 = CFrame.Angles(0, math.rad((data.yaw * -1) - 180), 0) * CFrame.Angles(math.rad(data.pitch * -1), 0, 0)
				entity.lastPos = entity.pos
				entity.yaw = math.rad((data.yaw * -1) - 180)
				entity.pitch = math.clamp(math.rad(data.pitch * -1), -(math.pi / 2), (math.pi / 2))
				entity.velocity = entity.lastPos and newCF.Position - entity.lastPos.Position or Vector3.zero
				entity.delta = os.clock()
				entity.onGround = data.onGround
				entity.pos = newCF
				slop.CameraController.setLook(entity.yaw, entity.pitch)
				tickFunc(0.01)
				setthreadidentity(8)
			end
		end
	
		tlayer.listeners.switch_slot = function(data)
			slop.InventoryController.selectSlot(data.slot + 1)
			handlers.world.olduse()
			setthreadidentity(8)
		end
	
		tlayer.listeners.attack = function(data)
			local entity = self:getEntity(data.id)
			if entity then
				attack(entity.State, (localState.position + Vector3.new(0, 1.62, 0)):Max(entity.State.position - Vector3.new(0.4, -0.1, 0.4)):Min(entity.State.position + Vector3.new(0.4, 1.9, 0.4)))
				setthreadidentity(8)
			end
		end
	
		tlayer.listeners.arm_animation = function()
			local clickQueue = debug.getupvalue(clickFunc, 4)
			local wakeQueue = debug.getupvalue(clickFunc, 5)
			if #clickQueue >= 80 then
				table.remove(clickQueue, 1)
			end
	
			table.insert(clickQueue, {
				pressTime = os.clock(),
				holdDuration = math.random() * 0.09,
				clickKind = 0,
				heldKey = Enum.UserInputType.MouseButton1
			})
	
			wakeQueue.wake()
			slop.ViewmodelController.swing_1()
			setthreadidentity(8)
		end
	
		tlayer.listeners.entity_action = function(data)
			if data.action == 0 or data.action == 1 then
				self.sneaking = data.action == 0
			elseif data.action == 3 or data.action == 4 then
				self.sprinting = data.action == 3
			end
		end
	end
	
	function handler:convertPosition(pos, entity, isMC)
		if isMC then
			return pos + Vector3.new(0.5, 127.64, 0.25)
		else
			return ((pos - Vector3.new(0.5, 127.64, 0.25)) * BLOCK_SIZE)
		end
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
		for _, v in self.threads do
			task.cancel(v)
		end
	
		for _, v in self.threads2 do
			task.cancel(v)
		end
	
		for _, func in self.hooks do
			restorefunction(func)
		end
	
		for _, v in self.entities do
			for _, v2 in v.Connections do
				v2:Disconnect()
			end
		end
	
		if self.character then
			for _, v in self.character.Connections do
				v:Disconnect()
			end
	
			self.character = nil
		end
	
		if self.old then
			debug.setupvalue(self.oldtick, 28, self.old)
			self.old = nil
		end
	
		if self.oldtick then
			debug.setupvalue(debug.getupvalue(slop.MovementController.start, 14), 5, self.oldtick)
			self.oldtick = nil
		end
	
		self.botId = -1
		self.sneaking = false
		self.sprinting = false
		table.clear(self.connections)
		table.clear(self.entities)
		table.clear(self.threads)
		table.clear(self.threads2)
		table.clear(self.hooks)
	end
	
	function handler:tick()
	
	end
	
	function handler:addEntity(state)
		if not state then return end
		local entity = {
			CId = state.id,
			Id = state.player and state.player.UserId or state.id,
			Health = 20,
			isOnFire = false,
			isSneaking = false,
			State = state,
			Player = state.player,
			Connections = {}
		}
	
		tlayer:send('entity_spawn', {
			id = entity.Id,
			type = 1,
			lplr = entity.Player == lplr,
			bot = not entity.Player,
			yaw = state.yaw or 0,
			pitch = state.pitch or 0,
			pos = self:convertPosition(state.position, entity, true)
		})
	
		if state.health then
			entity.Health = state.health
			tlayer:send('entity_health', {
				id = entity.Id,
				health = entity.Health
			})
		end
	
		if entity.Player ~= lplr then
			if entity.Player then
				tlayer:send('entity_state', {
					id = entity.Id,
					flag = 4,
					state = entity.Player:GetAttribute('itemUseStartTime') and true or false
				})
	
				table.insert(entity.Connections, entity.Player:GetAttributeChangedSignal('itemUseStartTime'):Connect(function()
					tlayer:send('entity_state', {
						id = entity.Id,
						flag = 4,
						state = entity.Player:GetAttribute('itemUseStartTime') and true or false
					})
				end))
	
				for slot, item in {'armorHead', 'armorChest', 'armorLegs', 'armorFeet'} do
					table.insert(entity.Connections, entity.Player:GetAttributeChangedSignal(item):Connect(function()
						self:updateArmor(entity.Id, slot, entity.Player:GetAttribute(item))
					end))
	
					self:updateArmor(entity.Id, slot, entity.Player:GetAttribute(item))
				end
	
				table.insert(entity.Connections, entity.Player:GetAttributeChangedSignal('heldItemId'):Connect(function()
					self:updateArmor(entity.Id, 5, entity.Player:GetAttribute('heldItemId'))
				end))
	
				self:updateArmor(entity.Id, 5, entity.Player:GetAttribute('heldItemId'))
			end
	
			table.insert(self.entities, entity)
		else
			handlers.gui:updateInv()
			self.character = entity
		end
	end
	
	function handler:removeEntity(char)
		if self.character and self.character.CId == char then
			for _, v in self.character.Connections do
				v:Disconnect()
			end
	
			self.character = nil
		end
	
		for index, entity in self.entities do
			if entity.CId == char then
				tlayer:send('entity_remove', {
					id = entity.Id
				})
	
				for _, v in entity.Connections do
					v:Disconnect()
				end
	
				table.remove(self.entities, index)
				break
			end
		end
	end
	
	function handler:getEntity(comp)
		if self.character and self.character.CId == comp then
			return self.character
		end
	
		for _, entity in self.entities do
			if entity.CId == comp or entity.Id == comp then
				return entity
			end
		end
	end
	
	function handler:updateArmor(id, slot, item)
		tlayer:send('entity_equipment', {
			id = id,
			slot = 5 - slot,
			item = {id = handlers.gui:convertItem({itemId = item}), count = 1}
		})
	end
	
	return handler
end)()

handlers.gui = (function()
	local ARMOR_TABLE = {'head', 'chest', 'legs', 'feet'}
	local handler = {
		Name = 'gui',
		connections = {},
		isOpen = false
	}
	
	function handler:start()
		self.old = debug.getupvalue(slop.InventoryController.start, 17)
	
		local hook
		hook = hookfunction(self.old, function(...)
			local res = table.pack(hook(...))
			task.spawn(handler.updateInv, handler)
	
			return unpack(res, 1, res.n)
		end)
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
		if self.old then
			restorefunction(self.old)
			self.old = nil
		end
	
		self.isOpen = false
		table.clear(self.connections)
	end
	
	function handler:updateInv()
		local slots = table.create(45, {id = 0, count = 0})
	
		for slot, item in debug.getupvalue(debug.getupvalue(slop.InventoryController.start, 5), 2) do
			if slot > 0 and slot < 10 then
				slots[slot + 35] = {id = self:convertItem(item), count = item.count or 1}
			end
	
			if slot > 34 and slot < 41 then
				slots[slot - 32] = {id = self:convertItem(item), count = item.count or 1}
			end
		end
	
		tlayer:send('window_items', {
			windowId = 0,
			slots = slots
		})
	end
	
	function handler:convertItem(item)
		if not item then
			return 0, 0
		end
	
		local id = types.items[item.itemId] or 1
		if type(id) == 'table' then
			if id[1] == true then
				return 0, id[2]
			end
	
			return bit32.bor(bit32.lshift(id[1], 16), id[2]), 0
		else
			return bit32.bor(bit32.lshift(id, 16), 0), 0
		end
	end
	
	return handler
end)()

handlers.misc = (function()
	local handler = {
		Name = 'misc',
		connections = {}
	}
	
	local COLORS = {Color3.fromRGB(85, 255, 85), Color3.fromRGB(170, 220, 255), Color3.fromRGB(85, 255, 255), Color3.fromRGB(255, 255, 85), Color3.fromRGB(255, 170, 0), Color3.fromRGB(255, 85, 85), Color3.fromRGB(255, 85, 255), Color3.fromRGB(170, 85, 255), Color3.fromRGB(255, 170, 170), Color3.fromRGB(255, 255, 255)}
	local function calculateLevelColor(level)
		return COLORS[(math.floor((math.max(1, level) - 1) / 10) % #COLORS) + 1]
	end
	
	local function xpForLevel(xp)
		local multi = math.max(1, math.floor(xp))
		return ((100 / 2) * multi) * (multi - 1)
	end
	
	function handler:start()
		self.connections = {
			lplr.OnTeleport:Connect(function()
				if not self.tpflag then
					self.tpflag = true
					tlayer:send('reconnect')
				end
			end),
		}
	
		self.oldchat = debug.getupvalue(debug.getupvalue(slop.ChatController.start, 21), 20)
		self.oldkill = debug.getupvalue(slop.EntitySoundRenderer.start, 2)
	
		local hook
		hook = hookfunction(self.oldchat, function(...)
			local msg, color = ...
			task.spawn(function()
				if type(msg) == 'string' then
					tlayer:send('chat', {
						message = msg
					})
				end
			end)
			return hook(...)
		end)
	
		local hook2
		hook2 = hookfunction(self.oldkill, function()
			task.spawn(function()
				handler:playLocalSound('random.orb')
				hook2()
			end)
		end)
	
		--[[self.oldchat = getcallbackvalue(textChatService, 'OnIncomingMessage')
		textChatService.OnIncomingMessage = function(message)
			if message.Status == Enum.TextChatMessageStatus.Success then
				local prefix = message.PrefixText
				local plr = message.TextSource and playersService:GetPlayerByUserId(message.TextSource.UserId)
				if plr then
					prefix = '<font color="#AAAAAA">[</font><font color="#'..calculateLevelColor(plr:GetAttribute('AccountLevel') or 0):ToHex()..'">'..(plr:GetAttribute('AccountLevel') or 0)..'</font><font color="#AAAAAA">] </font><font color="#'..(plr:GetAttribute('NameColor') and plr:GetAttribute('NameColor'):ToHex() or 'AAAAAA')..'">'..(plr.DisplayName or plr.Name)..'</font>:'
				end
	
				tlayer:send('chat', {
					message = prefix..' '..message.Text
				})
			end
		end]]
	
		--[[tlayer:send('experience', {
			experienceBar = lplr:GetAttribute('XPProgress') or 0,
			level = lplr:GetAttribute('XPLevel') or 1,
			totalExperience = lplr:GetAttribute('TotalXP') or 0
		})]]
	
		self.scoreboardthread = task.spawn(function()
			repeat
				self:sendScoreboard()
				task.wait(1)
			until false
		end)
	
		tlayer.listeners.chat = function(data)
			if data.text:lower():sub(1, 7) == '/reload' then
				return
			end
	
			slop.ChatController.submitText(data.text)
			setthreadidentity(8)
			--textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(data.text)
		end
	end
	
	function handler:sendScoreboard()
		local title = ''
		local lines = {}
	
		local suc, res = pcall(function()
			local gui = lplr.PlayerGui.Hud.Scoreboard.Container
			local sorted = {}
			for _, entry in gui:GetChildren() do
				if entry:IsA('Frame') then
					table.insert(sorted, entry)
				end
			end
	
			table.sort(sorted, function(a, b)
				return a.LayoutOrder < b.LayoutOrder
			end)
	
			for _, line in sorted do
				if line.Name == 'Title' then
					title = line.TextLabel.Text
					continue
				end
	
				local label = line:FindFirstChild('main')
				table.insert(lines, label and label.Text or ' ')
			end
		end)
	
		tlayer:send('scoreboard', {
			title = title,
			lines = lines
		})
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
		if self.hook then
			restorefunction(self.hook)
			self.hook = nil
		end
	
		if self.oldchat then
			restorefunction(self.oldchat)
			self.oldchat = nil
		end
	
		if self.oldkill then
			restorefunction(self.oldkill)
			self.oldkill = nil
		end
	
		if self.scoreboardthread then
			task.cancel(self.scoreboardthread)
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
end)()

handlers.tablist = (function()
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
	
				for _, attr in {'level'} do
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
			for _, attr in {'level'} do
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
				Prefix = '<font color="#AAAAAA">[</font><font color="#'..calculateLevelColor(plr:GetAttribute('level') or 0):ToHex()..'">'..(plr:GetAttribute('level') or 0)..'</font><font color="#AAAAAA">]</font><font color="#AAAAAA"> </font>',
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
end)()

handlers.world = (function()
	local handler = {
		Name = 'world',
		blocks = {},
		chunks = {},
		connections = {}
	}
	
	local CHUNK_SIZE = math.pow(16, 3)
	local BLANK_CHUNK = {palette = {}, cells = {}}
	local BLOCK_SIZE = 3
	local NORMALS = {
		[0] = Vector3.new(0, -1, 0),
		[1] = Vector3.new(0, 1, 0),
		[2] = Vector3.new(0, 0, -1),
		[3] = Vector3.new(0, 0, 1),
		[4] = Vector3.new(-1, 0, 0),
		[5] = Vector3.new(1, 0, 0)
	}
	
	local function getBlockOffset(pos)
		return bit32.bor(bit32.lshift(bit32.band(pos.Y, 15), 8), bit32.lshift(bit32.band(pos.Z, 15), 4), bit32.band(pos.X, 15))
	end
	
	local function loopClean(tab)
		for index, v in tab do
			if type(v) == 'table' then
				if index == 'palette' then
					table.clear(v)
					continue
				end
	
				loopClean(v)
			end
		end
	
		table.clear(tab)
	end
	
	local function getCellCenter(vec)
		return (vec - Vector3.new(1.5, -1, 1))
	end
	
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	
	local function parsePositions(v, func)
		if v:IsA('Part') then
			local cf = v.CFrame
			local start = -(v.Size / 2)
			local startpos = cf:PointToWorldSpace(-(v.Size / 2))
			local endpos = cf:PointToWorldSpace((v.Size / 2))
			local actualstart = Vector3.new(math.min(startpos.X, endpos.X), math.min(startpos.Y, endpos.Y), math.min(startpos.Z, endpos.Z))
			local actualend = Vector3.new(math.max(startpos.X, endpos.X), math.max(startpos.Y, endpos.Y), math.max(startpos.Z, endpos.Z))
			params.FilterDescendantsInstances = {v}
	
			for x = -6, (actualend.X - actualstart.X) + 6, BLOCK_SIZE do
				for y = -6, (actualend.Y - actualstart.Y) + 6, BLOCK_SIZE do
					for z = -6, (actualend.Z - actualstart.Z) + 6, BLOCK_SIZE do
						local point = (actualstart // 3 * 3) + Vector3.new(0, -0.5, -2.5) + Vector3.new(x, y, z)
						if point:Max(actualstart):Min(actualend) == point then
							func((point - Vector3.new(0, -0.5, -2.5)) - Vector3.new(0, 3, 3), v)
						end
						--func(Vector3.new(math.round(actualstart.X / 3) * 3, math.round(actualstart.Y / 3) * 3, math.round(actualstart.Z / 3) * 3) + Vector3.new(x, y, z), v)
					end
				end
			end
	
			--[[for x = -3, v.Size.X + 3, BLOCK_SIZE do
				for y = -3, v.Size.Y + 3, BLOCK_SIZE do
					for z = -3, v.Size.Z + 3, BLOCK_SIZE do
						local point = cf:PointToWorldSpace(start + Vector3.new(x, y, z) + Vector3.new(1.5, 1.5, 1.5))
						local clamp = point:Max(actualstart):Min(actualend)
						if point == clamp then
							func(point, v)
						end
					end
				end
			end]]
		end
	end
	
	function handler:start()
		local mapLoaded = false
		local updateUsing = debug.getupvalue(debug.getupvalue(slop.ItemUseController.start, 5), 10)
		local startUsing = debug.getupvalue(debug.getupvalue(slop.ItemUseController.start, 5), 18)
	
		self.connections = {
			workspace.Maps.DescendantAdded:Connect(function(v)
				parsePositions(v, function(pos)
					self.blocks[pos // BLOCK_SIZE] = v
					self:write(types.blocks[v.Name] or 1, pos // BLOCK_SIZE, v, mapLoaded)
				end)
			end),
			workspace.Maps.DescendantRemoving:Connect(function(v)
				parsePositions(v, function(pos)
					if self.blocks[pos // BLOCK_SIZE] == v then
						self.blocks[pos // BLOCK_SIZE] = nil
						self:write(0, pos // BLOCK_SIZE, v, mapLoaded)
					end
				end)
			end)
		}
	
		for _, v in workspace.Maps:GetDescendants() do
			parsePositions(v, function(pos)
				self.blocks[pos // BLOCK_SIZE] = v
				self:write(types.blocks[v.Name] or 1, pos // BLOCK_SIZE, v)
			end)
		end
	
		mapLoaded = true
	
		self.olduse = hookfunction(debug.getupvalue(slop.ItemUseController.start, 5), function() end)
	
		tlayer.listeners.chunk = function(data)
			if mapLoaded then
				tlayer:send('chunk', {
					x = data.x,
					z = data.z,
					chunk = self.chunks[data.x..' '..data.z] or {palette = {}, cells = {}}
				})
			end
		end
	
		tlayer.listeners.place = function(data)
			if data.face == -1 then
				local stack = slop.InventoryController.getSelectedStack()
				local itemData = stack and slop.ItemLookup[stack.itemId] or nil
				if itemData then
					startUsing(stack, itemData)
				end
	
				setthreadidentity(8)
			end
		end
	
		tlayer.listeners.dig = function(data)
			if data.status == 5 then
				handler.olduse()
				setthreadidentity(8)
			end
		end
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
		if self.olduse then
			restorefunction(debug.getupvalue(slop.ItemUseController.start, 5))
			self.olduse = nil
		end
	
		self.useData = nil
		self.breakPos = nil
		table.clear(self.connections)
		table.clear(self.chunks)
	end
	
	function handler:write(id, pos, block, update)
		local chunkPos = (pos + Vector3.new(0, 128, 0)) // 16
		local relPos = (pos - (chunkPos * 16))
		local chunkIndex = chunkPos.X..' '..chunkPos.Z
		local chunkY = chunkPos.Y * 16
	
		if not self.chunks[chunkIndex] then
			self.chunks[chunkIndex] = {palette = {}, cells = {}}
		end
	
		local chunk = self.chunks[chunkIndex]
		if not chunk.cells[chunkY] then
			chunk.cells[chunkY] = {}
		end
	
		if block and block.Name == 'bed' and pos ~= block.Position / 3 then
			id = types.blocks.bed_foot
		end
	
		local blockIndex = table.find(chunk.palette, id)
		if not blockIndex then
			table.insert(chunk.palette, id)
			blockIndex = #chunk.palette
		end
	
		if update then
			if type(id) == 'table' then
				tlayer:send('block_update', {
					id = bit32.bor(bit32.lshift(id[1], 4), id[2]),
					pos = Vector3.new(pos.X, pos.Y + 128, pos.Z)
				})
			else
				tlayer:send('block_update', {
					id = bit32.bor(bit32.lshift(id, 4), 0),
					pos = Vector3.new(pos.X, pos.Y + 128, pos.Z)
				})
			end
		end
	
		chunk.cells[chunkY][relPos] = blockIndex
	end
	
	return handler
end)()

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