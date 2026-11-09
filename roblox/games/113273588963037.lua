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

types.blocks = (function()
	return {
		grass = 2,
		dirt = 3,
		stone = 1,
		cobblestone = 4,
		mossy_cobblestone = 48,
		stone_bricks = 98,
		mossy_stone_bricks = {98, 1},
		cracked_stone_bricks = {98, 2},
		bricks = 45,
		oak_planks = 5,
		spruce_planks = {5, 1},
		birch_planks = {5, 2},
		oak_log = 17,
		spruce_log = {17, 1},
		birch_log = {17, 2},
		oak_leaves = 18,
		spruce_leaves = {18, 1},
		sand = 12,
		sandstone = 24,
		gravel = 13,
		clay = 82,
		glass = 20,
		obsidian = 49,
		iron_block = 42,
		gold_block = 41,
		diamond_block = 57,
		emerald_block = 133,
		lapis_block = 22,
		quartz_block = 155,
		glow_block = 89,
		hay_bale = 170,
		slime = 165,
		ice = 79,
		packed_ice = 174,
		mire_sand = 88,
		cobweb = 30,
		bookshelf = 47,
		cactus = 81,
		snow_block = 80,
		red_sandstone = 179,
		deep_stone = 1,
		oak_fence = 85,
		lava = 11,
		water = 9,
		stone_brick_slab = {44, 5},
		scorched_rock = 7,
		tall_grass = {31, 1},
		fire = 51,
		flower_red = 38,
		flower_yellow = 37,
		ladder_n = {65, 3},
		ladder_s = {65, 2},
		ladder_e = {65, 4},
		ladder_w = {65, 5},
		wool_black = {35, 15},
		wool_blue = {35, 11},
		wool_brown = {35, 12},
		wool_cyan = {35, 9},
		wool_gray = {35, 7},
		wool_green = {35, 13},
		wool_light_blue = {35, 3},
		wool_light_gray = {35, 8},
		wool_lime = {35, 5},
		wool_magenta = {35, 2},
		wool_orange = {35, 1},
		wool_pink = {35, 6},
		wool_purple = {35, 10},
		wool_red = {35, 14},
		wool_white = 35,
		wool_yellow = {35, 4}
	}
end)()

types.itemlimits = (function()
	return {}
end)()

types.items = (function()
	local data = {
		wood_sword = 268,
		wood_axe = 271,
		gold_sword = 283,
		gold_axe = 286,
		stone_sword = 272,
		stone_axe = 275,
		iron_sword = 267,
		iron_axe = 258,
		diamond_sword = 276,
		diamond_axe = 279,
		ruby_sword = 276,
		ruby_axe = 279,
		shadow_sword = 276,
		shadow_axe = 279,
		prism_sword = 276,
		prism_axe = 279,
		bow = 261,
		arrow = 262,
		golden_apple = 322,
		fishing_rod = 346,
		snowball = 332,
		warp_pearl = 368,
		lava_bucket = 327,
		water_bucket = 326,
		bucket = 325,
		leather_helmet = 298,
		gold_helmet = 314,
		chainmail_helmet = 302,
		iron_helmet = 306,
		diamond_helmet = 310,
		ruby_helmet = 310,
		prism_helmet = 310,
		shadow_helmet = 310,
		leather_chestplate = 299,
		gold_chestplate = 315,
		chainmail_chestplate = 303,
		iron_chestplate = 307,
		diamond_chestplate = 311,
		ruby_chestplate = 311,
		prism_chestplate = 311,
		shadow_chestplate = 311,
		leather_leggings = 300,
		gold_leggings = 316,
		chainmail_leggings = 304,
		iron_leggings = 308,
		diamond_leggings = 312,
		ruby_leggings = 312,
		prism_leggings = 312,
		shadow_leggings = 312,
		leather_boots = 301,
		gold_boots = 317,
		chainmail_boots = 305,
		iron_boots = 309,
		diamond_boots = 313,
		ruby_boots = 313,
		prism_boots = 313,
		shadow_boots = 313,
	}
	
	for i, v in types.blocks do
		--data[i] = v
	end
	
	return data
end)()

handlers.entity = (function()
	local BLOCK_SIZE = 3
	local ARMOR_TABLE = {'head', 'chest', 'legs', 'feet'}
	local ARMOR_INDEX = {
		['rbxassetid://130685775853745'] = 'leather',
		['rbxassetid://102610048662839'] = 'iron',
		['rbxassetid://119547713744589'] = 'gold',
		['rbxassetid://133478589959125'] = 'diamond',
		['rbxassetid://96870641567881'] = 'chainmail',
		['rbxassetid://118978454461259'] = 'diamond',
		['rbxassetid://113804280664421'] = 'diamond',
		['rbxassetid://117191533019784'] = 'diamond'
	}
	local ARMOR_MAP = {
		head = 'helmet',
		chest = 'chestplate',
		legs = 'leggings',
		feet = 'boots'
	}
	
	local handler = {
		Name = 'entity',
		entities = {},
		threads = {},
		threads2 = {},
		connections = {},
		aimC0 = CFrame.new(),
		botId = -1,
		sneaking = false,
		sprinting = false,
		spawned = false
	}
	
	function handler:start()
		local lastConfirmed
		local breakTimer = 0
		local queuedAttack
		--[[table.insert(self.connections, game:GetService('RunService').PreSimulation:Connect(function()
			local entity = self.character
			local root = entity and entity.RootPart
	
			if root and entity.pos then
				if lastConfirmed and lastConfirmed ~= root.Position then
					tlayer:send('teleport', {
						pos = self:convertPosition(root.Position, entity, true)
					})
	
					entity.velocity = Vector3.zero
					if (entity.pos.Position - root.Position).Magnitude < 1 then
						entity.lastPos = nil
					else
						return
					end
				end
	
				local movedir = (entity.velocity * Vector3.new(1, 0, 1)).Unit
				sethiddenproperty(entity.Humanoid, 'MoveDirectionInternal', movedir == movedir and movedir or Vector3.zero)
				root.CFrame = entity.lastPos and entity.lastPos:Lerp(entity.pos, math.clamp((os.clock() - entity.delta) / 0.05, 0, 1)) or entity.pos
				root.AssemblyLinearVelocity = entity.velocity
				entity.sentPos = root.Position
			end
		end))]]
	
		--[[table.insert(self.connections, game:GetService('RunService').Heartbeat:Connect(function()
			local entity = self.character
			local root = entity and entity.RootPart
	
			if root then
				lastConfirmed = root.Position
			end
		end))]]
	
		local tickFunc = debug.getupvalue(debug.getupvalue(upg.MovementController.start, 5), 11)
		local camFunc = debug.getupvalue(upg.CameraController.start, 4)
		local findFunc = debug.getupvalue(debug.getupvalue(upg.CombatController.init, 15), 17)
		local attackFunc = debug.getupvalue(debug.getupvalue(upg.CombatController.init, 15), 21)
		local cooldown = os.clock()
	
		self.oldtick = tickFunc
		self.oldinput = debug.getupvalue(tickFunc, 5)
		self.old = debug.getupvalue(tickFunc, 11)
		local setMoveYaw = upg.MovementController.setMoveYaw
	
		for _, connection in getconnections(replicatedStorage.Remotes.Knockback.OnClientEvent) do
			connection:Disconnect()
		end
	
		debug.setupvalue(debug.getupvalue(upg.MovementController.start, 5), 11, function() end)
		debug.setupvalue(tickFunc, 11, {
			step = function(...)
				local res = table.pack(handler.old.step(...))
				local state = ...
				local entity = handler.character
				local root = entity and entity.RootPart
	
				if entity and entity.pos then
					state.yaw = entity.yaw
					state.pitch = entity.pitch
					debug.setupvalue(tickFunc, 22, entity.yaw)
					debug.setupvalue(tickFunc, 12, entity.pitch)
					debug.setupvalue(camFunc, 16, entity.yaw)
					debug.setupvalue(camFunc, 19, entity.yaw)
					debug.setupvalue(camFunc, 20, entity.pitch)
					debug.setupvalue(camFunc, 22, entity.pitch)
	
					if queuedAttack then
						local state = upg.MovementController.getState()
	
						if state and cooldown < os.clock() then
							local suc1, data1 = pcall(upg.CameraController.getLook)
							if suc1 and data1 then
								local suc2, data2 = pcall(upg.CameraController.getRenderEye)
								local eyePos = suc2 and typeof(data2) == 'Vector3' and data2 or data1.eye
								local attacked, dist = findFunc(eyePos, self.aimC0.LookVector, 4.5, lplr.Character)
	
								if attacked and dist <= 3 then
									local isPlayer = playersService:GetPlayerFromCharacter(attacked) ~= nil
									replicatedStorage.Remotes.Swing:FireServer()
									attackFunc(attacked, state, eyePos, self.aimC0.LookVector, isPlayer, 1)
									cooldown = os.clock() + 0.5
								end
							end
						end
	
						queuedAttack = false
					end
	
					state.motion = entity.velocity / 3
					state.pos = entity.pos.Position / 3
					state.sprinting = handler.sprinting or false
					state.sneaking = handler.sneaking or false
					if entity.onGround then
						state.motion = Vector3.new(state.motion.X, math.min(state.motion.Y, -0.08 * 0.98), state.motion.Z)
					end
				end
	
				return unpack(res, 1, res.n)
			end,
			setEffects = self.old.setEffects
		})
	
		table.insert(self.connections, replicatedStorage.Remotes.HitFx.OnClientEvent:Connect(function(data)
			if data then
				local entity = self:getREntity(data.victim)
				if entity then
					local plr = entity.Player
					tlayer:send('entity_status', {
						id = entity.Id,
						status = 2
					})
	
					if data.crit then
						tlayer:send('entity_animation', {
							id = entity.Id,
							animation = 4
						})
					end
	
					if data.magic then
						tlayer:send('entity_animation', {
							id = entity.Id,
							animation = 5
						})
					end
	
					if plr ~= lplr and entity.Character.PrimaryPart then
						tlayer:send('play_sound', {
							sound = (entity.Character:GetAttribute('Health') or 100) <= 0 and 'game.player.die' or 'game.player.hurt',
							pos = self:convertPosition(entity.Character.PrimaryPart.Position, {HipHeight = 2, RootPart = entity.Character.PrimaryPart}, true),
							volume = 1,
							pitch = (math.random() - math.random()) * 0.2 + 1
						})
					end
				end
			end
		end))
	
		table.insert(self.connections, replicatedStorage.Remotes.SwingSync.OnClientEvent:Connect(function(id)
			local entity = self:getREntity(id)
			if entity and entity.Player ~= lplr then
				tlayer:send('entity_animation', {
					id = entity.Id,
					animation = 0
				})
			end
		end))
	
		table.insert(self.connections, collectionService:GetInstanceAddedSignal('Combatant'):Connect(function(char)
			self:addCharModel(char, true)
		end))
	
		table.insert(self.connections, collectionService:GetInstanceRemovedSignal('Combatant'):Connect(function(char)
			self:removeEntity(char)
		end))
	
		for _, char in collectionService:GetTagged('Combatant') do
			self:addCharModel(char)
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
				tickFunc()
				setthreadidentity(8)
			end
		end
	
		tlayer.listeners.switch_slot = function(data)
			local newslot = math.clamp(data.slot + 1, 1, 5)
			upg.DoAction('slot'..newslot, true)
			upg.InputTable.use = false
			setthreadidentity(8)
		end
	
		local function clampVec(pos, target, mag)
			if (pos - target).Magnitude > mag then
				return CFrame.lookAt(pos, target).LookVector
			else
				return target
			end
		end
	
		tlayer.listeners.attack = function(data)
			queuedAttack = true
		end
	
		tlayer.listeners.arm_animation = function()
	
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
			return ((pos - Vector3.new(0, entity.RootPart.Size.Y / 2 + entity.HipHeight, 0)) / BLOCK_SIZE) + Vector3.new(0, 128, 0)
		else
			return ((pos - Vector3.new(0, 128, 0)) * BLOCK_SIZE) + Vector3.new(0, 0, 0)
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
			debug.setupvalue(self.oldtick, 11, self.old)
			self.old = nil
		end
	
		if self.oldinput then
			debug.setupvalue(self.oldtick, 5, self.oldinput)
			self.oldinput = nil
		end
	
		if self.oldtick then
			debug.setupvalue(debug.getupvalue(upg.MovementController.start, 5), 11, self.oldtick)
			self.oldtick = nil
		end
	
		self.botId = -1
		self.sneaking = false
		self.sprinting = false
		table.clear(self.connections)
		table.clear(self.entities)
		table.clear(self.threads)
		table.clear(self.threads2)
	end
	
	function handler:tick()
		local data = debug.getupvalue(debug.getupvalue(upg.RemoteSync.init, 3), 2)
		for _, entity in self.entities do
			local entry = data[entity.CId]
			if entry then
				local newFlags = entry.flags[entry.head]
	
				if newFlags ~= entity.Flags then
					for i = 1, 2 do
						if bit32.band(newFlags, i) ~= bit32.band(entity.Flags, i) then
							tlayer:send('entity_state', {
								id = entity.Id,
								flag = i == 2 and 3 or 1,
								state = bit32.band(newFlags, i) ~= 0
							})
						end
					end
	
					entity.Flags = newFlags
				end
	
				tlayer:send('entity_move', {
					id = entity.Id,
					yaw = (math.deg(entry.yaws[entry.head] * -1) - 180) % 360,
					pitch = math.deg(entry.pitches[entry.head] * -1) % 360,
					pos = self:convertPosition((entry.ps[entry.head] + Vector3.new(0, 0.9, 0)) * BLOCK_SIZE, entity, true),
					onGround = bit32.band(newFlags, 4) ~= 0
				})
			end
		end
		--[[for _, entity in self.entities do
			local aimVec = entity.RootPart.CFrame.LookVector
	
			tlayer:send('entity_move', {
				id = entity.Id,
				yaw = (math.deg(math.atan2(aimVec.Z, aimVec.X)) - 90) % 360,
				pos = self:convertPosition(entity.RootPart.Position, entity, true)
			})
		end]]
	end
	
	function handler:addCharModel(char, isRespawn)
		if not self.threads2[char] then
			self.threads2[char] = task.delay(isRespawn and 0.3 or 0, function()
				local plr = playersService:GetPlayerFromCharacter(char)
				if not plr then
					self.botId -= 1
					plr = {UserId = self.botId}
				end
	
				self:addEntity(char, plr)
				if not plr.Name then
					handlers.tablist:sendTablist()
				end
	
				self.threads2[char] = nil
			end)
		end
	end
	
	function handler:addEntity(char, plr)
		if not char then return end
		if self.threads[char] then
			task.cancel(self.threads[char])
		end
	
		self.threads[char] = task.spawn(function()
			local hum = char:WaitForChild('Humanoid', 10)
			local rootpart = char:WaitForChild('HumanoidRootPart', 10)
	
			if hum and rootpart then
				local entity = {
					CId = char:GetAttribute('CombatantId'),
					Id = plr.UserId,
					RootPart = rootpart,
					Humanoid = hum,
					HipHeight = hum and hum.HipHeight or 0,
					Character = char,
					Player = plr,
					Connections = {},
					Flags = 4
				}
	
				local aimVec = rootpart.CFrame.LookVector
				tlayer:send('entity_spawn', {
					id = entity.Id,
					type = 1,
					lplr = plr == lplr,
					bot = typeof(plr) ~= 'Instance',
					yaw = math.floor((math.deg(math.atan2(aimVec.Z, aimVec.X)) - 90) % 360),
					pos = self:convertPosition(rootpart.Position, entity, true)
				})
	
				tlayer:send('entity_health', {
					id = entity.Id,
					health = (char:GetAttribute('Health') or 0)
				})
	
				tlayer:send('entity_absorption', {
					id = entity.Id,
					amount = char:GetAttribute('Absorption') or 0
				})
	
				table.insert(entity.Connections, char:GetAttributeChangedSignal('Health'):Connect(function()
					tlayer:send('entity_health', {
						id = entity.Id,
						health = (char:GetAttribute('Health') or 0)
					})
				end))
	
				table.insert(entity.Connections, char:GetAttributeChangedSignal('Absorption'):Connect(function()
					tlayer:send('entity_absorption', {
						id = entity.Id,
						amount = char:GetAttribute('Absorption') or 0
					})
				end))
	
				table.insert(entity.Connections, char:GetAttributeChangedSignal('Burning'):Connect(function()
					tlayer:send('entity_state', {
						id = entity.Id,
						flag = 0,
						state = char:GetAttribute('Burning') or false
					})
				end))
	
				if plr ~= lplr then
					table.insert(entity.Connections, char.ChildAdded:Connect(function(obj)
						self:guessArmor(entity.Id, obj, entity)
					end))
	
					table.insert(entity.Connections, char:GetAttributeChangedSignal('HeldItem'):Connect(function()
						self:updateArmor(entity.Id, 5, char:GetAttribute('HeldItem'))
					end))
	
					for _, obj in char:GetChildren() do
						self:guessArmor(entity.Id, obj, entity)
					end
	
					self:updateArmor(entity.Id, 5, char:GetAttribute('HeldItem'))
					--[[table.insert(entity.Connections, char.ChildAdded:Connect(function(tool)
						if tool:IsA('Tool') then
							self:updateArmor(entity.Id, 5, tool)
						end
					end))
	
					table.insert(entity.Connections, char.ChildRemoved:Connect(function(tool)
						if tool:IsA('Tool') then
							self:updateArmor(entity.Id, 5, nil)
						end
					end))
	
					local tool = char:FindFirstChildWhichIsA('Tool')
					self:updateArmor(entity.Id, 5, tool)]]
	
					table.insert(self.entities, entity)
				else
					handlers.gui:updateInv({'wood_sword'})
					self.character = entity
				end
			end
	
			self.threads[char] = nil
		end)
	end
	
	function handler:removeEntity(char)
		if self.threads[char] then
			task.cancel(self.threads[char])
			self.threads[char] = nil
		end
	
		if self.character and self.character.Character == char then
			for _, v in self.character.Connections do
				v:Disconnect()
			end
	
			self.character = nil
		end
	
		for index, entity in self.entities do
			if entity.Character == char then
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
	
	function handler:getEntity(char)
		for _, entity in self.entities do
			if entity.Character == char or entity.Id == char then
				return entity
			end
		end
	end
	
	function handler:getREntity(id)
		if self.character and self.character.CId == id then
			return self.character
		end
	
		for _, entity in self.entities do
			if entity.CId == id then
				return entity
			end
		end
	end
	
	function handler:guessArmor(id, obj, entity)
		if obj.Name:sub(1, 6) == 'Armor_' then
			local subbed = obj.Name:sub(7, #obj.Name)
			local atype = ARMOR_MAP[subbed]
			local cobj = obj:FindFirstChildWhichIsA('Texture', true)
	
			if atype and cobj and ARMOR_INDEX[cobj.Texture] and table.find(ARMOR_TABLE, subbed) then
				self:updateArmor(id, table.find(ARMOR_TABLE, subbed), ARMOR_INDEX[cobj.Texture]..'_'..atype)
			end
	
			table.insert(entity.Connections, obj.DescendantAdded:Connect(function(bobj)
				if bobj:IsA('Texture') then
					if atype and ARMOR_INDEX[bobj.Texture] and table.find(ARMOR_TABLE, subbed) then
						self:updateArmor(id, table.find(ARMOR_TABLE, subbed), ARMOR_INDEX[bobj.Texture]..'_'..atype)
					end
				end
			end))
		end
	end
	
	function handler:updateArmor(id, slot, item)
		tlayer:send('entity_equipment', {
			id = id,
			slot = 5 - slot,
			item = {id = handlers.gui:convertItem(item), count = 1}
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
		self:updateInv()
	
		table.insert(self.connections, upg.ClientState.InventoryChanged:Connect(function(inv)
			task.spawn(self.updateInv, self)
		end))
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
		self.isOpen = false
		table.clear(self.connections)
	end
	
	function handler:updateInv()
		local slots = table.create(45, {id = 0, count = 0})
	
		if upg.ClientState.inventory then
			for index, item in upg.ClientState.inventory.armor do
				local slot = table.find(ARMOR_TABLE, index)
				if slot then
					slots[slot + 4] = {id = self:convertItem(item.id), count = math.min(item.count or 1, types.itemlimits[item] or 127)}
				end
			end
	
			for index, item in upg.ClientState.inventory.hotbar do
				slots[35 + index] = {id = self:convertItem(item.id), count = math.min(item.count or 1, types.itemlimits[item] or 127)}
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
	
		local id = types.items[item] or 1
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
			upg.ClientState.ProfileChanged:Connect(function()
				task.spawn(function()
					if upg.ClientState.profile then
						local oldlevelxp = xpForLevel(upg.ClientState.profile.levelRewarded or 0)
						tlayer:send('experience', {
							experienceBar = math.clamp((upg.ClientState.profile.xp - oldlevelxp) / (xpForLevel((upg.ClientState.profile.levelRewarded or 0) + 1) - oldlevelxp), 0, 1),
							level = upg.ClientState.profile.levelRewarded or 0,
							totalExperience = upg.ClientState.profile.xp or 0
						})
	
						self:sendScoreboard()
					end
				end)
			end),
			upg.ClientState.UpgradeChanged:Connect(function()
				task.spawn(function()
					if upg.ClientState.upgrade then
						self:sendScoreboard()
					end
				end)
			end),
			upg.ClientState.Notified:Connect(function(data)
				task.spawn(function()
					if data.kind == 'broadcast' and data.event == 'runWon' and data.id == (lplr.Character and lplr.Character:GetAttribute('CombatantId') or -math.huge) then
						self:playLocalSound('random.levelup')
	
						tlayer:send('title', {
							action = 2,
							text = '',
							fadeIn = 3,
							stay = 50,
							fadeOut = 7
						})
	
						tlayer:send('title', {
							action = 0,
							text = '<font color="#FFAA00">RUN COMPLETE!</font>',
							fadeIn = 0,
							stay = 0,
							fadeOut = 0
						})
					end
				end)
			end),
			replicatedStorage.Remotes.KillFeed.OnClientEvent:Connect(function(data)
				if type(data) == 'table' and data.killerId == (lplr.Character and lplr.Character:GetAttribute('CombatantId') or -math.huge) then
					self:playLocalSound('random.orb')
				end
	
				local msg = data.killMessage and data.killMessage ~= '' and data.killMessage or 'killed'
				tlayer:send('chat', {
					message = `<font color="#ff5555">{data.killer} {msg} {data.victim}.</font>`
				})
			end)
		}
	
		self.oldchat = getcallbackvalue(textChatService, 'OnIncomingMessage')
		textChatService.OnIncomingMessage = function(message)
			if message.Status == Enum.TextChatMessageStatus.Success then
				tlayer:send('chat', {
					message = message.PrefixText..' '..message.Text
				})
			end
		end
	
		if upg.ClientState.profile then
			local oldlevelxp = xpForLevel(upg.ClientState.profile.levelRewarded or 0)
			tlayer:send('experience', {
				experienceBar = math.clamp((upg.ClientState.profile.xp - oldlevelxp) / (xpForLevel((upg.ClientState.profile.levelRewarded or 0) + 1) - oldlevelxp), 0, 1),
				level = upg.ClientState.profile.levelRewarded or 0,
				totalExperience = upg.ClientState.profile.xp or 0
			})
		end
	
		self:sendScoreboard()
	
		--[[tlayer:send('experience', {
			experienceBar = lplr:GetAttribute('XPProgress') or 0,
			level = lplr:GetAttribute('XPLevel') or 1,
			totalExperience = lplr:GetAttribute('TotalXP') or 0
		})]]
	
		--[[self.scoreboardthread = task.spawn(function()
			repeat
				self:sendScoreboard()
				task.wait(1)
			until false
		end)]]
	
		tlayer.listeners.chat = function(data)
			if data.text:lower():sub(1, 7) == '/reload' then
				return
			end
	
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(data.text)
		end
	end
	
	function handler:sendScoreboard()
		local lines = {}
		local upgrade = upg.ClientState.upgrade
		table.insert(lines, ' ')
	
		if upgrade then
			table.insert(lines, 'Upgrade: <font color="#'..(upgrade.phase == 'maxed' and 'FF5555' or '55FF55')..'">'..(upgrade.phase == 'maxed' and (not ((upgrade.stars or 0) > 0) and 'Maxed' or ('Maxed +%*'):format(upgrade.stars)) or ('%*/%*'):format(upgrade.index, upgrade.total))..'</font>')
			table.insert(lines, 'Streak: <font color="#55FF55">'..(upgrade.streak or 0)..'</font>')
		end
	
		table.insert(lines, ' ')
		if upg.ClientState.profile then
			table.insert(lines, 'Gold: <font color="#FFAA00">'..(upg.ClientState.profile.coins or 0)..'g</font>')
			table.insert(lines, 'Emeralds: <font color="#55FF55">'..(upg.ClientState.profile.emeralds or 0)..'</font>')
			table.insert(lines, 'Level: <font color="#55FF55">'..(upg.ClientState.profile.levelRewarded or 0)..'</font>')
		end
	
		tlayer:send('scoreboard', {
			title = '\255e\255lUPG PER KILL',
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
			textChatService.OnIncomingMessage = self.oldchat
			self.oldchat = nil
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
	
	local function parsePositions(v, func)
		if v:IsA('BasePart') then
			local cf = v.CFrame
			local start = -(v.Size / 2)
	
			for x = 0, v.Size.X - 0.001, BLOCK_SIZE do
				for y = 0, v.Size.Y - 0.001, BLOCK_SIZE do
					for z = 0, v.Size.Z - 0.001, BLOCK_SIZE do
						func((cf:PointToWorldSpace(start + Vector3.new(x, y, z)) // BLOCK_SIZE) * BLOCK_SIZE, v)
					end
				end
			end
		end
	end
	
	function handler:start()
		local mapLoaded = false
	
		self.connections = {
			workspace.World.DescendantAdded:Connect(function(v)
				parsePositions(v, function(pos)
					self.blocks[pos // BLOCK_SIZE] = v
					self:write(types.blocks[v.Name] or 1, pos // BLOCK_SIZE, v, mapLoaded)
				end)
			end),
			workspace.World.DescendantRemoving:Connect(function(v)
				parsePositions(v, function(pos)
					if self.blocks[pos // BLOCK_SIZE] == v then
						self.blocks[pos // BLOCK_SIZE] = nil
						self:write(0, pos // BLOCK_SIZE, v, mapLoaded)
					end
				end)
			end)
		}
	
		for _, v in workspace.World:GetDescendants() do
			parsePositions(v, function(pos)
				self.blocks[pos // BLOCK_SIZE] = v
				self:write(types.blocks[v.Name] or 1, pos // BLOCK_SIZE, v)
			end)
		end
	
		mapLoaded = true
	
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
				upg.InputTable.use = true
				upg.DoAction('use', true)
				setthreadidentity(8)
			end
		end
	
		tlayer.listeners.dig = function(data)
			if data.status == 5 then
				upg.InputTable.use = false
				upg.DoAction('use', false)
				setthreadidentity(8)
			end
		end
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
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