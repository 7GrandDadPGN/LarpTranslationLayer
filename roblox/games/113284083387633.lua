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

types.blocks = (function()
	return {
		MC_Basalt = 287,
		MC_Bedrock = 34,
		MC_Blackstone = 922,
		MC_Cobblestone = 12,
		MC_DarkOakPlanks = 19,
		MC_DeepslateBricks = 1134,
		MC_DeepslateTiles = 1130,
		MC_Dirt = 9,
		MC_GoldBlock = 173,
		MC_Grass = {8, 1},
		MC_Log = 49,
		MC_MCAcaciaWood = 75,
		MC_MCAndesite = 6,
		MC_MCAzalea = 1108,
		MC_MCAzaleaLeaves = 97,
		MC_MCBedrock = 34,
		MC_MCBlackConcrete = 723,
		MC_MCBlackConcretePowder = 739,
		MC_MCBlackStainedGlass = 314,
		MC_MCBlastFurnace = 839,
		MC_MCBookshelf = 177,
		MC_MCClay = 270,
		MC_MCCobbledDeepslate = 1122,
		MC_MCCrafter = 1154,
		MC_MCCraftingTable = 205,
		MC_MCCrimsonHyphae = 871,
		MC_MCCyanTerracotta = 491,
		MC_MCCyanWool = 149,
		MC_MCDarkPrismarine = 527,
		MC_MCDeepslate = 1121,
		MC_MCDiorite = 4,
		MC_MCEmeraldOre = 397,
		MC_MCEndStone = 392,
		MC_MCFarmland = 207,
		MC_MCFurnace = 208,
		MC_MCGlowstone = 293,
		MC_MCGravel = 40,
		MC_MCGrayConcrete = 715,
		MC_MCGrayConcretePowder = 731,
		MC_MCGrayStainedGlass = 306,
		MC_MCGrayTerracotta = 489,
		MC_MCGrayWool = 147,
		MC_MCHopper = 475,
		MC_MCIron = 174,
		MC_MCLightBlueConcrete = 711,
		MC_MCLightBlueTerracotta = 485,
		MC_MCLightBlueWool = 143,
		MC_MCLightGrayConcrete = 716,
		MC_MCLightGrayConcretePowder = 732,
		MC_MCLightGrayGlazedTerracotta = 700,
		MC_MCLightGrayStainedGlass = 307,
		MC_MCLightGrayWool = 148,
		MC_MCLimeTerracotta = 487,
		MC_MCLimeWool = 145,
		MC_MCLodestone = 921,
		MC_MCMangrove = 57,
		MC_MCMossBlock = 1114,
		MC_MCMudBrick = 330,
		MC_MCNetherWart = 670,
		MC_MCNoteBlock = 109,
		MC_MCObserver = 674,
		MC_MCOchreFroglight = 1148,
		MC_MCOxidizedCutCopper = 1011,
		MC_MCPiston = 138,
		MC_MCPurpleShulkerBox = 686,
		MC_MCRedConcrete = 722,
		MC_MCRedGlazedTerracotta = 706,
		MC_MCRedSandstone = 593,
		MC_MCRedShulkerBox = 690,
		MC_MCRedWool = 154,
		MC_MCRedstoneBlock = 473,
		MC_MCSeaLantern = 534,
		MC_MCStrippedDarkOakWood = 85,
		MC_MCStrippedSpruceLog = 61,
		MC_MCTintedGlass = 997,
		MC_MCTuff = 982,
		MC_MCTuffBrick = 991,
		MC_MCTuffBricks = 991,
		MC_MCVerdantFroglight = 1149,
		MC_MCWarpedPlanks = 882,
		MC_MCWhiteConcrete = 708,
		MC_MCWhiteStainedGlass = 299,
		MC_MCYellowConcrete = 712,
		MC_NetherBricks = 380,
		MC_Netherrack = 284,
		MC_Obsidian = 192,
		MC_Planks = 13,
		MC_Quartz = 476,
		MC_RedNetherBricks = 671,
		MC_Sandstone = 106,
		MC_Snow = 277,
		MC_SpruceLog = 50,
		MC_SprucePlanks = 14,
		MC_Stone = 1,
		MC_StoneBricks = 325
	}
end)()

types.effects = (function()
	return {
		speed = 0,
		slowness = 1,
		strength = 4,
		weakness = 17,
		regeneration = 9,
		absorption = 21,
		resistance = 10,
		fire_resistance = 11,
		invisibility = 13,
		jump_boost = 7,
		slow_falling = 27,
		levitation = 24,
		wither = 19,
		instant_health = 5
	}
end)()

types.enchants = (function()
	return {
		aqua_affinity = 0,
		bane_of_arthropods = 1,
		binding_curse = 2,
		blast_protection = 3,
		breach = 4,
		channeling = 5,
		density = 6,
		depth_strider = 7,
		efficiency = 8,
		feather_falling = 9,
		fire_aspect = 10,
		fire_protection = 11,
		flame = 12,
		fortune = 13,
		frost_walker = 14,
		impaling = 15,
		infinity = 16,
		knockback = 17,
		looting = 18,
		loyalty = 19,
		luck_of_the_sea = 20,
		lunge = 21,
		lure = 22,
		mending = 23,
		multishot = 24,
		piercing = 25,
		power = 26,
		projectile_protection = 27,
		protection = 28,
		punch = 29,
		quick_charge = 30,
		respiration = 31,
		riptide = 32,
		sharpness = 33,
		silk_touch = 34,
		smite = 35,
		soul_speed = 36,
		sweeping_edge = 37,
		swift_sneak = 38,
		thorns = 39,
		unbreaking = 40,
		vanishing_curse = 41,
		wind_burst = 42
	}
end)()

types.itemlimit = (function()
	return {}
end)()

types.items = (function()
	return {
		netherite_sword = 941,
		diamond_sword = 936,
		iron_sword = 931,
		netherite_axe = 944,
		diamond_axe = 939,
		mace = 1223,
		netherite_pickaxe = 943,
		netherite_shovel = 942,
		trident = 1331,
		netherite_spear = 1302,
		diamond_spear = 1301,
		bow = 894,
		crossbow = 1339,
		arrow = 895,
		fishing_rod = 1053,
		shield = 1295,
		totem_of_undying = 1303,
		elytra = 862,
		netherite_helmet = 978,
		netherite_chestplate = 979,
		netherite_leggings = 980,
		netherite_boots = 981,
		diamond_helmet = 970,
		diamond_chestplate = 971,
		diamond_leggings = 972,
		diamond_boots = 973,
		iron_helmet = 966,
		iron_chestplate = 967,
		iron_leggings = 968,
		iron_boots = 969,
		golden_helmet = 974,
		golden_chestplate = 975,
		golden_leggings = 976,
		golden_boots = 977,
		chainmail_helmet = 962,
		chainmail_chestplate = 963,
		chainmail_leggings = 964,
		chainmail_boots = 965,
		copper_helmet = 958,
		copper_chestplate = 959,
		copper_leggings = 960,
		copper_boots = 961,
		leather_helmet = 954,
		leather_chestplate = 955,
		leather_leggings = 956,
		leather_boots = 957,
		golden_apple = 986,
		enchanted_golden_apple = 987,
		cooked_beef = 1111,
		ender_pearl = 1115,
		wind_charge = 1219,
		firework_rocket = 1242,
		cobweb = 201,
		obsidian = 321,
		water_bucket = 1013,
		salmon_bucket = 1020,
		bucket = 1012,
		splash_potion = 1291,
		experience_bottle = 1217,
		potion = 1121,
		spyglass = 1055,
		stick = 946,
		rail = 835,
		tnt_minecart = 857,
		flint_and_steel = 891,
		cart_restock = 596,
		cannon_box = 592
	}
end)()

types.potions = (function()
	return {
		swiftness = 15,
		strength = 36,
		healing = 25,
		invisibility = 6,
		fire_resistance = 12,
		slow_falling = 41
	}
end)()

handlers.entity = (function()
	local BLOCK_SIZE = 3
	local ATTACK_SOUNDS = {
		crit = 'entity.player.attack.crit',
		knockback = 'entity.player.attack.knockback',
		nodamage = 'entity.player.attack.nodamage',
		strong = 'entity.player.attack.strong',
		sweep = 'entity.player.attack.sweep',
		weak = 'entity.player.attack.weak',
		lunge = 'item.spear.lunge_1',
		jab = 'item.spear.hit',
		jabMiss = 'item.spear.use',
		smash = 'item.mace.smash_ground',
		smashHeavy = 'item.mace.smash_ground_heavy',
		smashAir = 'item.mace.smash_air',
		spearCharge = "item.spear.attack"
	}
	
	local snapshot
	local handler = {
		Name = 'entity',
		connections = {},
		entities = {},
		threads = {},
		effects = {},
		aimC0 = CFrame.new(),
		botId = -1,
		sneaking = false,
		sprinting = false,
		spawned = false
	}
	
	function handler:start()
		self.connections = {
			replicatedStorage.GameShared.Remotes.Event.OnClientEvent:Connect(function(event, data)
				if event == 'hurt' then
					local entity = handler:getEntity(data.id, true)
					if entity then
						tlayer:send('entity_hurt', {
							id = entity.Id,
							damageType = data.type == 'fire' and 21 or 0
						})
	
						if entity.Player ~= lplr then
							tlayer:send('play_sound', {
								sound = data.type == 'fire' and 'entity.player.hurt_on_fire' or 'entity.generic.hurt',
								pos = self:convertPosition(entity.RootPart.Position, entity, true),
								volume = 1,
								pitch = (math.random() - math.random()) * 0.2 + 1,
								source = 7
							})
						end
					end
				elseif event == 'kbSet' then
					if self.character then
						tlayer:send('entity_velocity', {
							id = self.character.Id,
							velocity = data.v
						})
					end
				elseif event == 'push' then
					if self.character then
						if data.set then
							tlayer:send('entity_velocity', {
								id = self.character.Id,
								velocity = data.v
							})
						else
							tlayer:send('add_velocity', {
								velocity = data.v
							})
						end
					end
				elseif event == 'rocket' then
					self:addFirework(data.ticks)
				elseif event == 'teleport' and data.pos then
					tlayer:send('teleport', {
						pos = data.pos + Vector3.new(0, 128, 0)
					})
				elseif event == 'fx' then
					local entity = data.id and handler:getEntity(data.id, true) or nil
	
					if entity then
						if data.kind == 'swing' then
							if entity ~= self.character then
								tlayer:send('entity_animation', {
									id = entity.Id,
									animation = 0
								})
							end
						elseif data.kind == 'crit' then
							tlayer:send('entity_animation', {
								id = entity.Id,
								animation = 4
							})
						elseif data.kind == 'magicCrit' then
							tlayer:send('entity_animation', {
								id = entity.Id,
								animation = 5
							})
						elseif data.kind == 'totem' then
							tlayer:send('entity_event', {
								id = entity.Id,
								event = 35
							})
						elseif data.kind == 'burp' then
							tlayer:send('entity_event', {
								id = entity.Id,
								event = 9
							})
						elseif data.kind == 'throw' then
							tlayer:send('play_sound', {
								sound = 'entity.splash_potion.throw',
								pos = self:convertPosition(entity.RootPart.Position, entity, true),
								volume = 0.5,
								pitch = 0.4 / (math.random() * 0.4 + 0.8),
								source = 7
							})
						elseif data.kind == 'windThrow' then
							tlayer:send('play_sound', {
								sound = 'entity.wind_charge.throw',
								pos = self:convertPosition(entity.RootPart.Position, entity, true),
								volume = 0.5,
								pitch = 0.4 / (math.random() * 0.4 + 0.8),
								source = 7
							})
						elseif data.kind == 'rocket' then
							tlayer:send('play_sound', {
								sound = 'entity.firework_rocket.launch',
								pos = self:convertPosition(entity.RootPart.Position, entity, true),
								volume = 1,
								pitch = 1,
								source = 7
							})
						end
					end
	
					if data.kind == 'attackSound' then
						if data.at then
							if not ATTACK_SOUNDS[data.sound] then
								print('missing', data.sound)
							end
	
							tlayer:send('play_sound', {
								sound = ATTACK_SOUNDS[data.sound] or 'entity.player.attack.nodamage',
								pos = data.at + Vector3.new(0, 128, 0),
								volume = 1,
								pitch = 1,
								source = 7
							})
						end
					elseif data.kind == 'wind' then
						tlayer:send('play_sound', {
							sound = 'entity.wind_charge.wind_burst',
							pos = data.pos + Vector3.new(0, 128, 0),
							volume = 0.5,
							pitch = 0.36,
							source = 6
						})
					elseif data.kind == 'splash' then
						tlayer:send('play_sound', {
							sound = 'entity.splash_potion.break',
							pos = data.pos + Vector3.new(0, 128, 0),
							volume = 1,
							pitch = 1,
							source = 7
						})
					elseif data.kind == 'killSound' and lplr.Character and data.killer == lplr.Character:GetAttribute('EntityId') then
						handlers.misc:playLocalSound('entity.arrow.hit_player', 0.18, 0.45)
					end
				end
			end)
		}
	
		local startUse
		local didMove
	
		for _, temp in unstable.Controller.beforeTick do
			if debug.info(temp, 's'):find('Hands') then
				local func = debug.getupvalue(temp, 6)
				local func2 = debug.getupvalue(temp, 4)
	
				if type(func) == 'function' and debug.info(func, 'n') == 'attack' then
					snapshot = debug.getupvalue(func, 12)
				elseif type(func2) == 'function' and debug.info(func2, 'n') == 'startUse' then
					startUse = func2
				end
			end
		end
	
		for _, bind in getrendersteppedlist() do
			if bind.Name == 'MCController' then
				self.aimState = debug.getupvalue(bind.Function, 1)
				self.target = bind.Function
				self.tickfunc = debug.getupvalue(self.target, 7)
				self.old = debug.getupvalue(self.tickfunc, 18)
				debug.setupvalue(self.target, 7, function() end)
				debug.setupvalue(self.tickfunc, 18, setmetatable({
					tick = function(...)
						local state, input = ...
						local entity = handler.character
	
						if entity and entity.pos then
							state.prev = state.pos
							state.pos = entity.pos.Position - Vector3.new(0, 128, 0)
	
							if entity.onGround then
								state.fallDistance = 0
								if entity.gliding then
									entity.gliding = false
									tlayer:send('entity_state', {
										id = entity.Id,
										flag = 7,
										state = false
									})
								end
							elseif state.pos.Y < state.prev.Y then
								state.fallDistance += state.prev.Y - state.pos.Y
							end
	
							state.vel = entity.velocity
							state.onGround = entity.onGround or false
							state.gliding = entity.gliding or false
							state.f = 0
							state.sprinting = handler.sprinting or false
							state.sneaking = handler.sneaking or false
							state.j = false
							sent = state.pos
						end
	
						return state
					end
				}, {
					__index = self.old
				}))
	
				break
			end
		end
	
		local windhook
		windhook = hookfunction(unstable.Controller.scheduleBurst, function(...)
			local center, _, pushFor = ...
			task.spawn(function()
				local vel = pushFor(unstable.Controller.state, center)
				if vel then
					tlayer:send('add_velocity', {
						velocity = vel
					})
				end
			end)
	
			return windhook(...)
		end)
	
		self.windhook = true
		tlayer.listeners.move = function(data)
			local entity = self.character
			if entity then
				local newCF = CFrame.new(data.pos) * CFrame.Angles(0, math.rad((data.yaw * -1) - 180), 0)
	
				didMove = true
				self.aimC0 = CFrame.Angles(0, math.rad((data.yaw * -1) - 180), 0) * CFrame.Angles(math.rad(data.pitch * -1), 0, 0)
				entity.lastPos = entity.pos
				entity.yaw = math.rad((data.yaw * -1) - 180)
				entity.pitch = math.clamp(math.rad(data.pitch * -1), -(math.pi / 2), (math.pi / 2))
				entity.velocity = entity.lastPos and newCF.Position - entity.lastPos.Position or Vector3.zero
				entity.delta = os.clock()
				entity.onGround = data.onGround
				entity.pos = newCF
				handler.aimState.yaw = entity.yaw
				handler.aimState.pitch = entity.pitch
				self.tickfunc()
				handlers.gui:process()
				setthreadidentity(8)
			end
		end
	
		tlayer.listeners.switch_slot = function(data)
			task.spawn(unstable.Hands.select, data.slot + 1)
		end
	
		tlayer.listeners.attack = function(data)
			local entity = self:getEntity(data.id)
			if entity then
				local state = snapshot()
				state.predicted = true
				firePacket({
					a = 'attack',
					target = entity.Character:GetAttribute('EntityId'),
					st = state,
					pressMs = (math.random() * 50) // 1
				})
	
				setthreadidentity(8)
			end
		end
	
		tlayer.listeners.arm_animation = function()
			firePacket({a = 'swing'})
		end
	
		tlayer.listeners.use_item = function(data)
			if data.hand == 0 then
				task.spawn(startUse)
			end
		end
	
		tlayer.listeners.client_command = function(data)
			if data.action == 0 and unstable.Menus.onRespawn then
				task.spawn(unstable.Menus.onRespawn)
			end
		end
	
		tlayer.listeners.tick_end = function()
			if not didMove then
				self.tickfunc()
				handlers.gui:process()
				setthreadidentity(8)
			end
	
			if self.character then
				local equipped = unstable.Hands.inv.hotbar[unstable.Hands.inv.selected]
				local newArmor = lplr:GetAttribute('ArmorPoints') or 0
				local changes = {}
	
				if equipped ~= self.lastEquipped then
					local newDef = equipped and unstable.ItemTable[equipped.id] or {speed = 4}
					local oldDef = self.lastEquipped and unstable.ItemTable[self.lastEquipped.id] or {speed = 4}
	
					if newDef.speed ~= oldDef.speed then
						table.insert(changes, {
							key = 'generic.attack_speed',
							value = 4,
							modifiers = newDef.speed and newDef.speed ~= 4 and {
								{
									uuid = 'minecraft:base_attack_speed',
									amount = newDef.speed - 4,
									operation = 0
								}
							} or {}
						})
					end
	
					self.lastEquipped = equipped
				end
	
				if newArmor ~= self.lastArmor then
					table.insert(changes, {
						key = 'generic.armor',
						value = 0,
						modifiers = newArmor > 0 and {
							{
								uuid = 'minecraft:armor.chestplate',
								amount = newArmor,
								operation = 0
							}
						} or {}
					})
	
					self.lastArmor = newArmor
				end
	
				if #changes > 0 then
					tlayer:send('entity_attributes', {
						id = self.character.Id,
						attributes = httpService:JSONEncode(changes)
					})
				end
			end
	
			if self.firework then
				self.firework.ticks -= 1
				if self.firework.ticks <= 0 then
					tlayer:send('entity_remove', {
						id = self.firework.id
					})
	
					self.firework = nil
				end
			end
	
			didMove = false
		end
	
		tlayer.listeners.entity_action = function(data)
			if data.action == 1 or data.action == 2 then
				self.sprinting = data.action == 1
			elseif data.action == 6 then
				if self.character then
					self.character.gliding = true
				end
			elseif data.action > 6 then
				self.sneaking = data.action == 7
			end
		end
	end
	
	function handler:jab()
		local entity = self.character
	
		if entity then
			local equipped = unstable.Hands.inv.hotbar[unstable.Hands.inv.selected]
	
			if equipped and unstable.ItemTable[equipped.id].kind == 'spear' then
				firePacket({
					a = 'jab',
					st = snapshot()
				})
	
				local lunge = equipped.ench and equipped.ench.lunge or 0
				if lunge > 0 and lplr.Character:GetAttribute('CanSprint') then
					tlayer:send('entity_velocity', {
						id = entity.Id,
						velocity = entity.velocity + ((self.aimC0.LookVector * Vector3.new(1, 0, 1)) * (0.458 * lunge))
					})
	
					unstable.Controller.lungedAt = unstable.Controller.tickCount
				end
	
				setthreadidentity(8)
			end
		end
	end
	
	function handler:addPlayers()
		table.insert(self.connections, playersService.PlayerAdded:Connect(function(plr)
			self:addPlayer(plr)
		end))
	
		for _, plr in playersService:GetPlayers() do
			self:addPlayer(plr)
		end
	end
	
	function handler:convertPosition(pos, entity, isMC)
		if isMC then
			return ((pos - Vector3.new(0, entity.RootPart.Size.Y / 2 + entity.HipHeight, 0)) / 3) + Vector3.new(0, 128, 0)
		else
			return ((pos - Vector3.new(0, 128, 0)) * 3) + Vector3.new(0, (entity.RootPart.Size.Y / 2 + entity.HipHeight), 0)
		end
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
		for _, v in self.threads do
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
	
		if self.target then
			debug.setupvalue(self.tickfunc, 18, self.old)
			debug.setupvalue(self.target, 7, self.tickfunc)
			self.target = nil
			self.tickfunc = nil
			self.old = nil
		end
	
		if self.windhook then
			restorefunction(unstable.Controller.scheduleBurst)
			self.windhook = nil
		end
	
		snapshot = nil
		self.botId = -1
		self.firework = nil
		self.sneaking = false
		self.sprinting = false
		self.aimState = nil
		self.lastEquipped = nil
		self.lastArmor = nil
		table.clear(self.connections)
		table.clear(self.entities)
		table.clear(self.threads)
		table.clear(self.effects)
	end
	
	function handler:tick()
		for _, entity in self.entities do
			local _, x = entity.RootPart.CFrame:ToEulerAnglesYXZ()
			local pos = self:convertPosition(entity.RootPart.Position, entity, true)
	
			tlayer:send('entity_move', {
				id = entity.Id,
				yaw = (math.deg(x * -1) - 180) % 360,
				pitch = math.deg((unstable.PitchTable[entity.PitchSlot] or 0) * -1),
				pos = pos
			})
	
			if (entity.Using == 'eat' or entity.Using == 'drink') and (os.clock() - entity.SoundTimer) > 0.2 then
				tlayer:send('play_sound', {
					sound = 'entity.generic.'..entity.Using,
					pos = pos,
					volume = entity.Using == 'eat' and (math.random() > 0.5 and 0.5 or 1) or 0.5,
					pitch = entity.Using == 'eat' and 1 + (math.random() - math.random()) * 0.2 or 0.9 + math.random() * 0.1,
					source = 7
				})
	
				entity.SoundTimer = os.clock()
			end
		end
	end
	
	function handler:addEntity(char, plr)
		if not char then return end
		if self.threads[char] then
			task.cancel(self.threads[char])
		end
	
		self.threads[char] = task.spawn(function()
			local hum = char:WaitForChild('Humanoid', 10)
			local head = char:WaitForChild('Head', 10)
			local rootpart = char:WaitForChild('HumanoidRootPart', 10)
	
			if hum and rootpart and head then
				local entity = {
					Id = plr.UserId,
					RootPart = rootpart,
					Humanoid = hum,
					Head = head,
					HipHeight = hum and hum.HipHeight or 0,
					Character = char,
					Player = plr,
					Connections = {},
					Effects = {},
					SoundTimer = 0,
					PitchSlot = char:GetAttribute('LookSlot'),
					Using = ''
				}
	
				local y, x = entity.Head.CFrame:ToEulerAnglesYXZ()
				tlayer:send('entity_spawn', {
					id = entity.Id,
					type = 1,
					lplr = plr == lplr,
					yaw = (math.deg(x * -1) - 180) % 360,
					pitch = math.deg(y * -1),
					pos = self:convertPosition(rootpart.Position, entity, true)
				})
	
				tlayer:send('entity_health', {
					id = entity.Id,
					health = (char:GetAttribute('Health') or 20)
				})
	
				tlayer:send('entity_absorption', {
					id = entity.Id,
					amount = char:GetAttribute('Absorption') or 0
				})
	
				tlayer:send('entity_state', {
					id = entity.Id,
					flag = 0,
					state = char:GetAttribute('OnFire') or false
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
	
				table.insert(entity.Connections, char:GetAttributeChangedSignal('OnFire'):Connect(function()
					tlayer:send('entity_state', {
						id = entity.Id,
						flag = 0,
						state = char:GetAttribute('OnFire') or false
					})
				end))
	
				table.insert(entity.Connections, char:GetAttributeChangedSignal('Gliding'):Connect(function()
					entity.gliding = char:GetAttribute('Gliding') or false
	
					tlayer:send('entity_state', {
						id = entity.Id,
						flag = 7,
						state = char:GetAttribute('Gliding') or false
					})
				end))
	
				if plr ~= lplr then
					table.insert(entity.Connections, char:GetAttributeChangedSignal('Offhand'):Connect(function()
						self:updateArmor(entity.Id, 5, char:GetAttribute('Offhand'))
					end))
	
					table.insert(entity.Connections, char:GetAttributeChangedSignal('Held'):Connect(function()
						self:updateArmor(entity.Id, 6, char:GetAttribute('Held'))
					end))
	
					table.insert(entity.Connections, char:GetAttributeChangedSignal('Armor'):Connect(function()
						self:decodeArmor(entity.Id, char:GetAttribute('Armor'))
					end))
	
					table.insert(entity.Connections, char:GetAttributeChangedSignal('Sneaking'):Connect(function()
						tlayer:send('entity_state', {
							id = entity.Id,
							flag = 1,
							state = char:GetAttribute('Sneaking') or false
						})
					end))
	
					table.insert(entity.Connections, char:GetAttributeChangedSignal('Using'):Connect(function()
						tlayer:send('entity_state', {
							id = entity.Id,
							flag = 2,
							state = (char:GetAttribute('UsingHand') or '') == 'off',
							living = true
						})
	
						tlayer:send('entity_state', {
							id = entity.Id,
							flag = 1,
							state = (char:GetAttribute('Using') or '') ~= '',
							living = true
						})
	
						entity.Using = char:GetAttribute('Using') or ''
					end))
	
					tlayer:send('entity_state', {
						id = entity.Id,
						flag = 1,
						state = char:GetAttribute('Sneaking') or false
					})
	
					tlayer:send('entity_state', {
						id = entity.Id,
						flag = 7,
						state = char:GetAttribute('Gliding') or false
					})
	
					tlayer:send('entity_state', {
						id = entity.Id,
						flag = 2,
						state = (char:GetAttribute('UsingHand') or '') == 'off',
						living = true
					})
	
					tlayer:send('entity_state', {
						id = entity.Id,
						flag = 1,
						state = (char:GetAttribute('Using') or '') ~= '',
						living = true
					})
	
					self:updateArmor(entity.Id, 5, char:GetAttribute('Offhand'))
					self:updateArmor(entity.Id, 6, char:GetAttribute('Held'))
					self:decodeArmor(entity.Id, char:GetAttribute('Armor'))
	
					table.insert(self.entities, entity)
				else
					for _, attribute in {'Food', 'Saturation'} do
						table.insert(entity.Connections, lplr:GetAttributeChangedSignal(attribute):Connect(function()
							tlayer:send('update_hunger', {
								hunger = lplr:GetAttribute('Food') or 20,
								saturation = lplr:GetAttribute('Saturation') or 20
							})
						end))
					end
	
					table.insert(entity.Connections, lplr:GetAttributeChangedSignal('Effects'):Connect(function()
						self:processEffects()
					end))
	
					tlayer:send('held_item_slot', {
						slot = (unstable.Hands.inv and unstable.Hands.inv.selected or 1) - 1
					})
	
					tlayer:send('update_hunger', {
						hunger = lplr:GetAttribute('Food') or 20,
						saturation = lplr:GetAttribute('Saturation') or 20
					})
	
					handlers.misc:replicateXP()
					entity.gliding = char:GetAttribute('Gliding') or false
					self.character = entity
					self:processEffects()
				end
			end
	
			self.threads[char] = nil
		end)
	end
	
	function handler:addFirework(ticks)
		if self.firework then
			tlayer:send('entity_remove', {
				id = self.firework.id
			})
		end
	
		if self.character then
			self.firework = {id = handler.botId, ticks = ticks or 20}
			handler.botId -= 1
	
			tlayer:send('entity_spawn', {
				id = self.firework.id,
				type = 2,
				lplr = false,
				yaw = 0,
				pitch = 0,
				pos = self.character.pos.Position
			})
	
			tlayer:send('entity_metadata', {
				id = self.firework.id,
				metadata = httpService:JSONEncode({
					{
						key = 9,
						value = 2
					}
				})
			})
		end
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
	
	function handler:getEntity(char, isLocal)
		if isLocal and self.character and self.character.Id == char then
			return self.character
		end
	
		for _, entity in self.entities do
			if entity.Character == char or entity.Id == char then
				return entity
			end
		end
	end
	
	function handler:decodeArmor(id, armor)
		if not armor then
			return
		end
	
		local decoded = httpService:JSONDecode(armor)
		for i, v in {'head', 'chest', 'legs', 'feet'} do
			self:updateArmor(id, i, decoded[v])
		end
	end
	
	function handler:updateArmor(id, slot, item)
		local decoded = type(item) ~= 'string' and item or item ~= '' and httpService:JSONDecode(item)
		item = decoded and handlers.gui:convertItem(decoded) or {id = 0, count = 0}
	
		tlayer:send('entity_equipment', {
			id = id,
			slot = 6 - slot,
			item = item
		})
	end
	
	function handler:processEffects()
		if self.character then
			local found = {}
			local effectStr = lplr:GetAttribute('Effects')
	
			if effectStr and #effectStr > 0 then
				for _, effect in effectStr:split(',') do
					local effectData = effect:split(':')
					table.insert(found, types.effects[effectData[1]] or 1)
	
					tlayer:send('entity_effect', {
						id = self.character.Id,
						effectId = types.effects[effectData[1]] or 1,
						amplifier = tonumber(effectData[2]),
						duration = tonumber(effectData[3]),
						flags = 14
					})
				end
			end
	
			for _, effect in self.effects do
				if not table.find(found, effect) then
					tlayer:send('remove_entity_effect', {
						id = self.character.Id,
						effectId = effect
					})
				end
			end
	
			self.effects = found
		end
	end
	
	function handler:addPlayer(plr)
		table.insert(self.connections, plr.CharacterAdded:Connect(function(char)
			self:addEntity(char, plr)
		end))
	
		table.insert(self.connections, plr.CharacterRemoving:Connect(function(char)
			self:removeEntity(char)
		end))
	
		if plr.Character then
			task.spawn(self.addEntity, self, plr.Character, plr)
		end
	end
	
	return handler
end)()

handlers.gui = (function()
	local ARMOR_TABLE = {'head', 'chest', 'legs', 'feet'}
	
	local CONVERT_SLOTS = {
		[5] = 101,
		[6] = 102,
		[7] = 103,
		[8] = 104
	}
	
	local handler = {
		Name = 'gui',
		connections = {},
		queue = {},
		waitTicks = 0,
		isOpen = false
	}
	
	function handler:start()
		self.connections = {
			replicatedStorage.GameShared.Remotes.Event.OnClientEvent:Connect(function(event, data)
				if event == 'inv' then
					task.defer(function()
						self:updateInv()
					end)
				end
			end)
		}
	
		for i = 1, 10 do
			CONVERT_SLOTS[35 + i] = i
		end
	
		for i = 1, 27 do
			CONVERT_SLOTS[8 + i] = 10 + i
		end
	
		self:updateInv()
	
		tlayer.listeners.click_slot = function(data)
			if data.windowId == 0 then
				local target = CONVERT_SLOTS[data.slot]
	
				if target then
					if data.action == 1 then
						self:queueAction({
							a = 'inv',
							op = 'click',
							slot = target,
							shift = true,
							right = false
						})
	
						return
					elseif data.action == 2 then
						self:queueAction({
							a = 'inv',
							op = 'key',
							slot = target,
							target = (data.mouseButton == 40 and 9 or data.mouseButton) + 1
						})
	
						return
					end
				end
	
				self:updateInv()
			end
		end
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
	
	function handler:queueAction(data)
		if #self.queue <= 0 then
			self.waitTicks = 1
			firePacket({
				a = 'inv',
				op = 'open'
			})
		end
	
		table.insert(self.queue, data)
	end
	
	function handler:process()
		if #self.queue > 0 then
			if self.waitTicks > 0 then
				self.waitTicks -= 1
				return
			end
	
			for _, v in self.queue do
				firePacket(v)
			end
	
			firePacket({
				a = 'inv',
				op = 'close'
			})
	
			table.clear(self.queue)
		end
	end
	
	function handler:swap()
		local inv = unstable.Hands.inv
		local old = inv.hotbar[inv.selected]
		inv.hotbar[inv.selected] = inv.offhand
		inv.offhand = inv.hotbar[inv.selected]
		firePacket({a = 'swap'})
		self:updateInv()
	end
	
	function handler:updateInv()
		local slots = table.create(46, {id = 0, count = 0})
		local inv = unstable.Hands.inv
	
		if inv then
			for slot, item in inv.armor do
				slots[table.find(ARMOR_TABLE, slot) + 5] = self:convertItem(item)
			end
	
			for slot, item in inv.inventory do
				slots[slot + 9] = self:convertItem(item)
			end
	
			for slot, item in inv.hotbar do
				slots[slot + 36] = self:convertItem(item)
			end
	
			if inv.offhand then
				slots[46] = self:convertItem(inv.offhand)
			end
		end
	
		tlayer:send('window_items', {
			windowId = 0,
			slots = slots
		})
	end
	
	function handler:convertItem(item)
		if not item then
			return {id = 0, count = 0}
		end
	
		local nbt = {}
		if item.ench and next(item.ench) then
			local ench = {}
			for enchantId, level in item.ench do
				table.insert(ench, {id = types.enchants[enchantId] or 1, level = level})
			end
	
			table.insert(nbt, {
				type = 'enchantments',
				data = {
					enchantments = ench
				}
			})
		elseif item.g then
			table.insert(nbt, {
				type = 'enchantments',
				data = {
					enchantments = {{id = types.enchants.protection, level = 1}}
				}
			})
		end
	
		if item.potion or item.p then
			table.insert(nbt, {
				type = 'potion_contents',
				data = {
					potionId = (types.potions[item.potion or item.p] or 1),
					customEffects = {}
				}
			})
		end
	
		if item.customName or item.n then
			table.insert(nbt, {
				type = 'custom_name',
				data = item.customName or item.n
			})
		end
	
		if item.dmg then
			table.insert(nbt, {
				type = 'damage',
				data = item.dmg
			})
		end
	
		local id = types.items[item.id] or 1
		if type(id) == 'table' then
			id = bit32.bor(bit32.lshift(id[1], 16), id[2])
		else
			id = bit32.bor(bit32.lshift(id, 16), 0)
		end
	
		return {id = id, count = item.c or item.count, nbt = #nbt > 0 and httpService:JSONEncode(nbt) or nil}
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
	
	local function getLevelXp(level)
		level = math.max(level, 1)
		if level >= 1000 then
			return 0
		end
	
		return math.floor(((((level - 1) ^ 2) * 0.045276) + 32.4) + 0.5)
	end
	
	function handler:start()
		self.connections = {
			lplr.OnTeleport:Connect(function()
				if not self.tpflag then
					self.tpflag = true
					tlayer:send('reconnect')
				end
			end),
			lplr:GetAttributeChangedSignal('TotalKills'):Connect(function()
				self:replicateXP()
			end)
		}
	
		self.oldchat = unstable.Chat.add
		self.oldchatpart = unstable.Chat.addParts
		self.oldsound = unstable.FX.sound
	
		self:replicateXP()
	
		local chatfunc
		for _, connection in getconnections(debug.getupvalue(unstable.Chat.close, 4).TextBox.FocusLost) do
			chatfunc = debug.getupvalue(connection.Function, 4)
			break
		end
	
		local chathook
		chathook = hookfunction(self.oldchat, function(...)
			local msg, color = ...
			task.spawn(function()
				if type(msg) == 'string' then
					tlayer:send('chat', {
						message = '<font color="#'..(color or Color3.new(1, 1, 1)):ToHex()..'">'..msg..'</font>'
					})
				end
			end)
	
			return chathook(...)
		end)
	
		local chathookparts
		chathookparts = hookfunction(self.oldchatpart, function(...)
			local parts = ...
			task.spawn(function()
				local msg = ''
				for _, entry in parts do
					msg ..= '<font color="#'..(entry[2]:ToHex())..'">'..entry[1]..'</font>'
				end
	
				tlayer:send('chat', {
					message = msg
				})
			end)
	
			return chathookparts(...)
		end)
	
		hookfunction(unstable.FX.sound, function() end)
	
		self.scoreboardthread = task.spawn(function()
			repeat
				self:sendScoreboard()
				task.wait(1)
			until false
		end)
	
		tlayer.listeners.chat = function(data)
			if data.text == 'reload' then
				handlers.entity:addFirework(40)
				return
			end
	
			chatfunc(data.text)
			setthreadidentity(8)
		end
	end
	
	function handler:replicateXP()
		tlayer:send('experience', {
			experienceBar = 0,
			level = lplr:GetAttribute('TotalKills') or 1,
			totalExperience = 0
		})
	end
	
	function handler:sendScoreboard()
		local title = '<font color="#A020F0">Unstable FFA</font>'
		local lines = {}
		local mapTimer = math.max((workspace:GetAttribute('ArenaResetAt') or workspace:GetServerTimeNow()) - workspace:GetServerTimeNow(), 0)
	
		table.insert(lines, ' ')
		table.insert(lines, 'Kit: <font color="#63ff63">'..(lplr:GetAttribute('Kit') or 'None')..'</font>')
		table.insert(lines, 'Killstreak: <font color="#ff5555">'..(lplr:GetAttribute('Streak') or 0)..'</font>')
		table.insert(lines, 'Next Map: <font color="#00d4f9">'..string.format('%d:%02d', mapTimer // 60, mapTimer % 60)..'</font>')
		table.insert(lines, ' ')
		table.insert(lines, 'Kills: <font color="#ffc933">'..(lplr:GetAttribute('TotalKills') or 0)..'</font>')
	
		tlayer:send('scoreboard', {
			title = title,
			lines = lines
		})
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
		if self.oldchat then
			restorefunction(self.oldchat)
			self.oldchat = nil
		end
	
		if self.oldchatpart then
			restorefunction(self.oldchatpart)
			self.oldchatpart = nil
		end
	
		if self.oldsound then
			restorefunction(self.oldsound)
			self.oldsound = nil
		end
	
		if self.scoreboardthread then
			task.cancel(self.scoreboardthread)
		end
	
		table.clear(self.connections)
	end
	
	function handler:playLocalSound(sound, volume, pitch)
		local char = handlers.entity.character
		if char and char.pos then
			tlayer:send('play_sound', {
				sound = sound,
				pos = char.pos.Position + Vector3.new(0, 128, 0),
				volume = volume or 1,
				pitch = pitch or 1,
				source = 5
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
	
	function handler:start()
		self:sendTablist()
		self.connections = {
			playersService.PlayerAdded:Connect(function(plr)
				self:sendTablist()
			end),
			playersService.PlayerRemoving:Connect(function()
				self:sendTablist()
			end)
		}
	end
	
	function handler:sendTablist()
		local data = {}
		for _, plr in playersService:GetPlayers() do
			table.insert(data, {
				Name = plr.Name,
				UserId = plr.UserId,
				isLocal = plr == lplr,
				Prefix = '<font color="#AAAAAA">]</font><font color="#AAAAAA"> </font>',
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
	
	local mapLoaded = false
	local tpCheck = false
	
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
		local cf = v.CFrame
		local start = -(v.Size / 2) + Vector3.new(BLOCK_SIZE / 2, BLOCK_SIZE / 2, BLOCK_SIZE / 2)
	
		for x = 0, v.Size.X - 1, BLOCK_SIZE do
			for y = 0, v.Size.Y - 1, BLOCK_SIZE do
				for z = 0, v.Size.Z - 1, BLOCK_SIZE do
					func(cf:PointToWorldSpace(start + Vector3.new(x, y, z)), v)
				end
			end
		end
	end
	
	function handler:start()
		self.connections = {
			replicatedStorage.GameShared.Remotes.Event.OnClientEvent:Connect(function(event, data)
				if event == 'fx' and data.kind == 'break' then
					self.blocks[data.pos // 1] = nil
					self:write(0, data.pos // 1, nil, mapLoaded)
	
					tlayer:send('play_sound', {
						sound = 'block.stone.break',
						pos = data.pos + Vector3.new(0, 128, 0),
						volume = 1,
						pitch = 1,
						source = 4
					})
				elseif event == 'teleport' then
					tpCheck = false
				end
			end)
		}
	
		for _, folder in {workspace.MCWorld.Solid, workspace.MCWorld.Webs, workspace.MCWorld.Fire} do
			table.insert(self.connections, folder.ChildAdded:Connect(function(v)
				if v:IsA('BasePart') then
					parsePositions(v, function(pos)
						self.blocks[pos // BLOCK_SIZE] = v
						self:write(types.blocks[v.MaterialVariant] or (v.Name == 'Cobweb' and 129 or 1), pos // BLOCK_SIZE, v, mapLoaded)
					end)
				end
			end))
	
			table.insert(self.connections, folder.ChildRemoved:Connect(function(v)
				if v:IsA('BasePart') then
					parsePositions(v, function(pos)
						if self.blocks[pos // BLOCK_SIZE] == v then
							self.blocks[pos // BLOCK_SIZE] = nil
							self:write(0, pos // BLOCK_SIZE, v, mapLoaded)
						end
					end)
				end
			end))
		end
		self:loadMap()
	
		tlayer.listeners.chunk = function(data)
			if mapLoaded then
				tlayer:send('chunk', {
					x = data.x,
					z = data.z,
					chunk = self.chunks[data.x..' '..data.z] or {palette = {}, cells = {}}
				})
			end
		end
	
		tlayer.listeners.dig = function(data)
			if data.status == 0 then
				firePacket({a = 'breakStart', cell = (data.pos - Vector3.new(0, 128, 0))})
			elseif data.status == 2 then
				firePacket({a = 'breakEnd', cell = (data.pos - Vector3.new(0, 128, 0))})
			elseif data.status == 5 then
				task.spawn(unstable.Hands.stopUsing, false)
				setthreadidentity(8)
			elseif data.status == 6 then
				handlers.gui:swap()
			elseif data.status == 7 then
				handlers.entity:jab()
			end
		end
	end
	
	function handler:loadMap(didRemove)
		mapLoaded = false
		tlayer:send('reload_world')
		if self.loadthread then
			task.cancel(self.loadthread)
			self.loadthread = nil
		end
	
		loopClean(self.chunks)
	
		local map
		for _, v in workspace.MCWorld.Solid:GetChildren() do
			if (not ((v.Name:find('Practice') or v.Name:find('Duel')) and not workspace:GetAttribute('DuelServer'))) and v.Name ~= 'Barrier' and v:IsA('Folder') then
				map = v
				break
			end
		end
	
		if map then
			self.loadconnection = map.AncestryChanged:Once(function(parent)
				self:loadMap(true)
			end)
	
			self.loadthread = task.spawn(function()
				local timeTaken = os.clock()
	
				for _, v in map:QueryDescendants('Part') do
					if (os.clock() - timeTaken) > 2 then
						task.wait(0.2)
						timeTaken = os.clock()
					end
	
					parsePositions(v, function(pos)
						self.blocks[pos // BLOCK_SIZE] = v
						self:write(types.blocks[v.MaterialVariant] or 1, pos // BLOCK_SIZE, v)
					end)
				end
	
				for _, folder in {workspace.MCWorld.Solid, workspace.MCWorld.Webs, workspace.MCWorld.Fire} do
					for _, v in folder:GetChildren() do
						if v:IsA('BasePart') then
							parsePositions(v, function(pos)
								self.blocks[pos // BLOCK_SIZE] = v
								self:write(types.blocks[v.MaterialVariant] or (v.Name == 'Cobweb' and 129 or 1), pos // BLOCK_SIZE, v)
							end)
						end
					end
				end
	
				mapLoaded = true
				if not didRemove then
					handlers.entity:addPlayers()
				end
	
				self.loadthread = nil
			end)
		end
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
		if self.loadthread then
			task.cancel(self.loadthread)
			self.loadthread = nil
		end
	
		if self.loadconnection then
			self.loadconnection:Disconnect()
			self.loadconnection = nil
		end
	
		loopClean(self.chunks)
		table.clear(self.connections)
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