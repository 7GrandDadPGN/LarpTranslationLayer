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

types.blocks = (function()
	return {
		AquaBricks = 168,
		Bricks = 45,
		Cobblestone = 4,
		ConcreteBlack = {159, 15},
		ConcreteBlue = {159, 11},
		ConcreteBrown = {159, 12},
		ConcreteCyan = {159, 9},
		ConcreteGray = {159, 7},
		ConcreteGreen = {159, 13},
		ConcreteLightBlue = {159, 3},
		ConcreteLightGray = {159, 8},
		ConcreteLime = {159, 5},
		ConcreteMagenta = {159, 2},
		ConcreteOrange = {159, 1},
		ConcretePink = {159, 6},
		ConcretePowderBlack = {159, 15},
		ConcretePowderBlue = {159, 11},
		ConcretePowderBrown = {159, 12},
		ConcretePowderCyan = {159, 9},
		ConcretePowderGray = {159, 7},
		ConcretePowderGreen = {159, 13},
		ConcretePowderLightBlue = {159, 3},
		ConcretePowderLightGray = {159, 8},
		ConcretePowderLime = {159, 5},
		ConcretePowderMagenta = {159, 2},
		ConcretePowderOrange = {159, 1},
		ConcretePowderPink = {159, 6},
		ConcretePowderPurple = {159, 10},
		ConcretePowderRed = {159, 14},
		ConcretePowderWhite = 159,
		ConcretePowderYellow = {159, 4},
		ConcretePurple = {159, 10},
		ConcreteRed = {159, 14},
		ConcreteSmoothBlack = {159, 15},
		ConcreteSmoothBlue = {159, 11},
		ConcreteSmoothBrown = {159, 12},
		ConcreteSmoothCyan = {159, 9},
		ConcreteSmoothGray = {159, 7},
		ConcreteSmoothGreen = {159, 5},
		ConcreteSmoothLightBlue = {159, 3},
		ConcreteSmoothLightGray = {159, 8},
		ConcreteSmoothLime = {159, 5},
		ConcreteSmoothMagenta = {159, 2},
		ConcreteSmoothOrange = {159, 1},
		ConcreteSmoothPink = {159, 6},
		ConcreteSmoothPurple = {159, 10},
		ConcreteSmoothRed = {159, 14},
		ConcreteSmoothWhite = 159,
		ConcreteSmoothYellow = {159, 4},
		ConcreteWhite = 159,
		ConcreteYellow = {159, 4},
		DarkRedBricks = 45,
		Dirt = 3,
		DiscoBlock = 1,
		DiscoBlockBlack = 1,
		DiscoBlockBlue = 1,
		DiscoBlockBrown = 1,
		DiscoBlockCyan = 1,
		DiscoBlockGray = 1,
		DiscoBlockGreen = 1,
		DiscoBlockLightBlue = 1,
		DiscoBlockLightGray = 1,
		DiscoBlockLime = 1,
		DiscoBlockMagenta = 1,
		DiscoBlockOrange = 1,
		DiscoBlockPink = 1,
		DiscoBlockPurple = 1,
		DiscoBlockRed = 1,
		DiscoBlockWhite = 1,
		DiscoBlockYellow = 1,
		Forcefield = 1,
		Glass = 20,
		GlassBlack = {95, 15},
		GlassBlue = {95, 11},
		GlassBrown = {95, 12},
		GlassCyan = {95, 9},
		GlassGray = {95, 7},
		GlassGreen = {95, 13},
		GlassLightBlue = {95, 3},
		GlassLightGray = {95, 8},
		GlassLime = {95, 5},
		GlassMagenta = {95, 2},
		GlassOrange = {95, 1},
		GlassPink = {95, 6},
		GlassPurple = {95, 10},
		GlassRed = {95, 14},
		GlassWhite = 95,
		GlassYellow = {95, 4},
		Grass = 2,
		Ice = 79,
		Iron = 42,
		Landmine = 1,
		Launchpad = 1,
		Logs = 17,
		Planks = 5,
		PolishedAndesite = {1, 6},
		PolishedDiorite = {1, 4},
		PolishedGranite = {1, 2},
		PrimaryPart = {54, 2},
		Quartz = 155,
		QuartzPillar = {155, 2},
		Sand = 12,
		SeaBricks = 168,
		ShimBlock = 1,
		SmoothSandstone = {24, 2},
		SmoothSandstoneRed = {179, 2},
		SmoothStone = {1, 6},
		Snow = 80,
		Stone = 1,
		StoneBricks = 98,
		TeamConcrete = 159,
		Terracotta = 172,
		TerracottaBlack = {159, 15},
		TerracottaBlue = {159, 11},
		TerracottaBrown = {159, 12},
		TerracottaCyan = {159, 9},
		TerracottaGray = {159, 7},
		TerracottaGreen = {159, 13},
		TerracottaLightBlue = {159, 3},
		TerracottaLightGray = {159, 8},
		TerracottaLime = {159, 5},
		TerracottaMagenta = {159, 2},
		TerracottaOrange = {159, 1},
		TerracottaPink = {159, 6},
		TerracottaPurple = {159, 10},
		TerracottaRed = {159, 14},
		TerracottaWhite = 159,
		TerracottaYellow = {159, 4}
	}
	
	
end)()

types.itemlimits = (function()
	local data = {
		Bow = 1,
		BronzePickaxe = 1,
		BronzeSword = 1,
		DiamondPickaxe = 1,
		DiamondSword = 1,
		EmeraldSword = 1,
		GoldPickaxe = 1,
		GoldSword = 1,
		IronPickaxe = 1,
		IronSword = 1,
		OnyxPickaxe = 1,
		OnyxSword = 1
	}
	
	return data
end)()

types.items = (function()
	local data = {
		Arrow = 262,
		Bow = 261,
		BronzeChestplate = 299,
		BronzeCoin = 334,
		BronzeHelmet = 298,
		BronzeLeggings = 300,
		BronzePickaxe = 270,
		BronzeSword = 268,
		Capybara = 332,
		DiamondChestplate = 311,
		DiamondHelmet = 310,
		DiamondLeggings = 312,
		DiamondPickaxe = 278,
		DiamondSword = 276,
		Dynamite = 332,
		EasterIslandHead = 1,
		EmeraldChestplate = 311,
		EmeraldHelmet = 310,
		EmeraldLeggings = 312,
		EmeraldSword = 276,
		Fish = 349,
		FishingRod = 346,
		GoldChestplate = 315,
		GoldCoin = 266,
		GoldHelmet = 314,
		GoldLeggings = 316,
		GoldPickaxe = 285,
		GoldSword = 283,
		Ice = 79,
		IronChestplate = 307,
		IronCoin = 265,
		IronHelmet = 306,
		IronLeggings = 308,
		IronPickaxe = 257,
		IronSword = 267,
		Landmine = 46,
		OnyxChestplate = 311,
		OnyxHelmet = 310,
		OnyxLeggings = 312,
		OnyxPickaxe = 278,
		OnyxSword = 276,
		PogoStick = 280,
		Adrenaline = 373,
		JumpBoost = {373, 8203},
		LifeSteal = 373,
		Shield = 322,
		SpeedBoost = {373, 8194},
		Shard = 409,
		SmokeGrenade = 344,
		Snowball = 332,
		Teleporter = 368,
		Tornado = 280,
		stick = 280
	}
	
	for index, value in types.blocks do
		data[index] = value
	end
	
	return data
end)()

handlers.entity = (function()
	local SWING_ANIMATIONS = {
		['rbxassetid://8542350607'] = true,
		['rbxassetid://8542347276'] = true,
		['rbxassetid://8542349245'] = true
	}
	
	local handler = {
		Name = 'entity',
		entities = {},
		threads = {},
		connections = {}
	}
	
	function handler:start()
		self.olddamage = skywars.HealthController.animateDamage
	
		skywars.HealthController.animateDamage = function(...)
			local self, target = ...
			local plr = playersService:GetPlayerFromCharacter(target)
			if plr then
				tlayer:send('entity_status', {
					id = plr.UserId,
					status = 2
				})
	
				if plr ~= lplr and target.PrimaryPart then
					tlayer:send('play_sound', {
						sound = (plr:GetAttribute('Health') or 100) <= 0 and 'game.player.die' or 'game.player.hurt',
						pos = self:convertPosition(target.PrimaryPart.Position, {HipHeight = 2, RootPart = target.PrimaryPart}, true),
						volume = 1,
						pitch = (math.random() - math.random()) * 0.2 + 1
					})
				end
			end
		end
	
		local lastConfirmed
		local breakTimer = 0
		table.insert(self.connections, game:GetService('RunService').PreSimulation:Connect(function()
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
	
				if skywars.CameraController.locked then
					skywars.CameraController:unlockCamera()
					setthreadidentity(8)
				end
	
				if handlers.world.breakPos and (handlers.world.breakPos - root.Position).Magnitude < 30 and breakTimer < os.clock() then
					breakTimer = os.clock() + 0.016
					skywars.Remotes[remotes.hitBlock]:fire(handlers.world.breakPos)
					setthreadidentity(8)
				end
	
				local movedir = (entity.velocity * Vector3.new(1, 0, 1)).Unit
				sethiddenproperty(entity.Humanoid, 'MoveDirectionInternal', movedir == movedir and movedir or Vector3.zero)
				root.CFrame = entity.lastPos and entity.lastPos:Lerp(entity.pos, math.clamp((os.clock() - entity.delta) / 0.05, 0, 1)) or entity.pos
				root.AssemblyLinearVelocity = entity.velocity
				entity.sentPos = root.Position
			end
		end))
	
		table.insert(self.connections, game:GetService('RunService').Heartbeat:Connect(function()
			local entity = self.character
			local root = entity and entity.RootPart
	
			if root then
				lastConfirmed = root.Position
			end
		end))
	
		table.insert(self.connections, debug.getupvalue(debug.getupvalue(skywars.Remotes[remotes['EndScreenController:onStart']].connect, 1).fireClient, 1).OnClientEvent:Connect(function(...)
			local victim, killer = ...
			if killer then
				tlayer:send('chat', {
					message = '/c/c'..victim.Name..' was killed by '..killer.Name
				})
			else
				tlayer:send('chat', {
					message = '/c/c'..victim.Name..' died.'
				})
			end
		end))
	
		table.insert(self.connections, playersService.PlayerAdded:Connect(function(plr)
			self:addPlayer(plr)
		end))
	
		for _, plr in playersService:GetPlayers() do
			self:addPlayer(plr)
		end
	
		tlayer.listeners.move = function(data)
			local entity = self.character
			if entity then
				data.pos = self:convertPosition(data.pos, entity, false)
				local newCF = CFrame.new(data.pos) * CFrame.Angles(0, math.rad((data.yaw * -1) - 180), 0)
	
				entity.lastPos = entity.pos
				entity.yaw = data.yaw
				entity.pitch = data.pitch
				entity.velocity = entity.lastPos and newCF.Position - entity.lastPos.Position or Vector3.zero
				entity.delta = os.clock()
				entity.pos = newCF
			end
		end
	
		tlayer.listeners.switch_slot = function(data)
			skywars.HotbarController:setActiveSlot(data.slot)
			setthreadidentity(8)
		end
	
		tlayer.listeners.attack = function(data)
			local entity = self:getEntity(data.id)
			if entity then
				skywars.Remotes[remotes.strikeDesktop]:fire(entity.Player)
				setthreadidentity(8)
			end
		end
	
		tlayer.listeners.arm_animation = function()
			local store = skywars.Store:getState()
			local equipped = store.Inventory.Contents[store.ActiveSlot]
	
			if equipped and skywars.ItemMeta[equipped.Type].Melee then
				skywars.MeleeController:playAnimation(lplr.Character, skywars.ItemMeta[equipped.Type])
				setthreadidentity(8)
			end
		end
	end
	
	function handler:convertPosition(pos, entity, isMC)
		if isMC then
			return ((pos - Vector3.new(0, entity.RootPart.Size.Y / 2 + entity.HipHeight, 0)) / 3) + Vector3.new(0.5, 128.5, 0.5)
		else
			return ((pos - Vector3.new(0.5, 128.5, 0.5)) * 3) + Vector3.new(0, (entity.RootPart.Size.Y / 2 + entity.HipHeight), 0)
		end
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
		if self.olddamage then
			skywars.HealthController.animateDamage = self.olddamage
			self.olddamage = nil
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
		end
	
		table.clear(self.connections)
		table.clear(self.entities)
		table.clear(self.threads)
	end
	
	function handler:tick()
		for _, entity in self.entities do
			local aimVec = entity.RootPart.CFrame.LookVector
	
			tlayer:send('entity_move', {
				id = entity.Id,
				yaw = (math.deg(math.atan2(aimVec.Z, aimVec.X)) - 90) % 360,
				pos = self:convertPosition(entity.RootPart.Position, entity, true)
			})
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
			local animator = hum and hum:WaitForChild('Animator', 10)
	
			if hum and rootpart then
				local entity = {
					Id = plr.UserId,
					RootPart = rootpart,
					Humanoid = hum,
					HipHeight = hum and hum.HipHeight or 0,
					Character = char,
					Player = plr,
					Connections = {}
				}
	
				local aimVec = rootpart.CFrame.LookVector
				tlayer:send('entity_spawn', {
					id = entity.Id,
					type = 1,
					lplr = plr == lplr,
					yaw = math.floor((math.deg(math.atan2(aimVec.Z, aimVec.X)) - 90) % 360),
					pos = self:convertPosition(rootpart.Position, entity, true)
				})
	
				tlayer:send('entity_health', {
					id = entity.Id,
					health = (plr:GetAttribute('Health') or 100) / 5
				})
	
				table.insert(entity.Connections, plr:GetAttributeChangedSignal('Health'):Connect(function()
					local health = (plr:GetAttribute('Health') or 100)
					tlayer:send('entity_health', {
						id = entity.Id,
						health = health / 5
					})
				end))
	
				if plr ~= lplr then
					if animator then
						table.insert(entity.Connections, animator.AnimationPlayed:Connect(function(anim)
							if SWING_ANIMATIONS[anim.Animation.AnimationId] then
								tlayer:send('entity_animation', {
									id = entity.Id,
									animation = 0
								})
							end
						end))
					end
	
					for slot, item in {'Helmet', 'Chestplate', 'Leggings'} do
						table.insert(entity.Connections, plr:GetAttributeChangedSignal(item):Connect(function()
							self:updateArmor(entity.Id, slot, plr:GetAttribute(item))
						end))
	
						self:updateArmor(entity.Id, slot, plr:GetAttribute(item))
					end
	
					table.insert(entity.Connections, char.ChildAdded:Connect(function(tool)
						if tool:IsA('Tool') then
							self:updateArmor(entity.Id, 5, tool.Name)
						end
					end))
	
					table.insert(entity.Connections, char.ChildRemoved:Connect(function(tool)
						if tool:IsA('Tool') then
							self:updateArmor(entity.Id, 5, nil)
						end
					end))
	
					local tool = char:FindFirstChildWhichIsA('Tool')
					self:updateArmor(entity.Id, 5, tool and tool.Name or nil)
	
					table.insert(self.entities, entity)
				else
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
	
	function handler:updateArmor(id, slot, item)
		tlayer:send('entity_equipment', {
			id = id,
			slot = 5 - slot,
			item = {id = handlers.gui:convertItem(item and {Type = item} or nil), count = 1}
		})
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
	local ARMOR_TABLE = {'Helmet', 'Chestplate', 'Leggings'}
	local handler = {
		Name = 'gui',
		connections = {},
		isOpen = false
	}
	
	function handler:start()
		local connection = skywars.Store.changed:connect(function(...)
			self:updateInv(...)
		end)
	
		table.insert(self.connections, {Disconnect = function()
			connection:disconnect()
		end})
	
		for _, item in {'Helmet', 'Chestplate', 'Leggings'} do
			table.insert(self.connections, lplr:GetAttributeChangedSignal(item):Connect(function()
				self:updateInv(skywars.Store:getState(), {Inventory = {}})
			end))
		end
	
		self:updateInv(skywars.Store:getState(), {Inventory = {}})
	
		tlayer.listeners.close_window = function()
			skywars.ScreenController:closeFocusedScreens()
			setthreadidentity(8)
		end
	
		tlayer.listeners.click_slot = function(data)
			local state = skywars.Store:getState()
			--print(data.windowId, data.slot, data.action, data.mouseButton)
			if data.windowId == 1 and state.Chest then
				if data.slot < 18 then
					for _, item in state.Chest.Contents do
						if item.Slot == data.slot then
							skywars.ChestController:updateChest(item.Slot, item.Type, -item.Quantity)
							return
						end
					end
				end
			elseif data.windowId == 0 then
				if data.slot > 8 and data.action == 2 then
					local index = data.slot < 36 and data.slot or data.slot - 36
					for _, item in state.Inventory.Contents do
						if item.Slot == index then
							skywars.InventoryController:moveItemToSlot(item, data.mouseButton)
							return
						end
					end
	
					for _, item in state.Inventory.Contents do
						if item.Slot == data.mouseButton then
							skywars.InventoryController:moveItemToSlot(item, index)
							return
						end
					end
				end
			end
	
			self:updateInv(state, {Inventory = {}})
		end
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
		self.isOpen = false
		table.clear(self.connections)
	end
	
	function handler:updateInv(newStore, oldStore)
		if newStore.Chest ~= oldStore.Chest then
			local isOpen = newStore.Chest ~= nil
			if isOpen ~= self.isOpen then
				if isOpen then
					tlayer:send('open_window', {
						name = 'minecraft:chest',
						windowId = 1,
						slots = 18
					})
	
					local slots = table.create(27, {id = 0, count = 0})
					for _, item in newStore.Chest.Contents do
						slots[item.Slot] = {id = self:convertItem(item), count = math.min(item.Quantity or 1, types.itemlimits[item.Type] or 127)}
					end
	
					tlayer:send('window_items', {
						windowId = 1,
						slots = slots
					})
				end
	
				self.isOpen = isOpen
			end
		end
	
		if newStore.Inventory.Contents ~= oldStore.Inventory.Contents then
			local slots = table.create(45, {id = 0, count = 0})
	
			for _, item in (lplr.Character and lplr.Character:GetChildren() or {}) do
				if item:GetAttribute('Armour') and skywars.ItemMeta[item.Name] then
					local index = table.find(ARMOR_TABLE, skywars.ItemMeta[item.Name].ItemGroup)
					if index then
						slots[index + 4] = {id = self:convertItem({Type = item.Name}), count = 1}
					end
				end
			end
	
			for _, item in newStore.Inventory.Contents do
				slots[(item.Slot < 9 and 36 or 0) + item.Slot] = {id = self:convertItem(item), count = math.min(item.Quantity or 1, types.itemlimits[item.Type] or 127)}
			end
	
			tlayer:send('window_items', {
				windowId = 0,
				slots = slots
			})
		end
	end
	
	function handler:convertItem(item)
		if not item then
			return 0, 0
		end
	
		local id = types.items[item.Type] or types.items.stick
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
	
	function handler:start()
		self.connections = {
			lplr.OnTeleport:Connect(function()
				if not self.tpflag then
					self.tpflag = true
					tlayer:send('reconnect')
				end
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
	
		local connection = skywars.Store.changed:connect(function(newStore, oldStore)
			if newStore.QueueStartTime ~= oldStore.QueueStartTime then
				if newStore.QueueStartTime ~= 0 then
					self:playLocalSound('portal.portal')
					tlayer:send('chat', {
						message = '\n/c/2Searching for match\n'
					})
				else
					tlayer:send('chat', {
						message = '\n/c/cQueue cancelled.\n'
					})
				end
			end
		end)
	
		table.insert(self.connections, {Disconnect = function()
			connection:disconnect()
		end})
	
		self.scoreboardthread = task.spawn(function()
			repeat
				self:sendScoreboard()
				task.wait(1)
			until false
		end)
	
		tlayer.listeners.chat = function(data)
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(data.text)
		end
	end
	
	function handler:sendScoreboard()
		local lines = {}
		local state = skywars.Store:getState()
		local diff = math.max(workspace:GetServerTimeNow() - (state.GameStateChangeTime or 0), 0)
		local map = workspace.BlockContainer:FindFirstChild('Map')
	
		table.insert(lines, '<font color="#AAAAAA">'..DateTime.now():FormatUniversalTime('MM/DD/YY', 'en-us')..'</font>')
		table.insert(lines, ' ')
		table.insert(lines, 'Time played: ')
		table.insert(lines, '<font color="#55FF55">'..(diff // 60)..':'..string.format('%02i', diff % 60)..'</font>')
		table.insert(lines, ' ')
		table.insert(lines, 'Players left: <font color="#55FF55">'..#(state.Players or {})..'</font>')
		table.insert(lines, ' ')
		table.insert(lines, 'Kills: <font color="#55FF55">'..(skywars.HealthController.kills or 0)..'</font>')
		table.insert(lines, ' ')
		table.insert(lines, 'Map: <font color="#55FF55">'..(map and map:GetAttribute('MapName') or 'None')..'</font>')
		table.insert(lines, 'Mode: <font color="#FF5555">Insane</font>')
	
	
		tlayer:send('scoreboard', {
			title = '\255e\255lSKYWARS',
			lines = lines
		})
	end
	
	function handler:clean()
		for _, v in self.connections do
			v:Disconnect()
		end
	
		if self.scoreboardthread then
			task.cancel(self.scoreboardthread)
		end
	
		if self.oldchat then
			textChatService.OnIncomingMessage = self.oldchat
			self.oldchat = nil
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
	
	function handler:start()
		self:sendTablist()
		self.connections = {
			playersService.PlayerAdded:Connect(function(plr)
				self:sendTablist()
				table.insert(self.connections, plr:GetAttributeChangedSignal('TeamId'):Connect(function()
					self:sendTablist()
				end))
			end),
			playersService.PlayerRemoving:Connect(function()
				self:sendTablist()
			end)
		}
	
		for _, plr in playersService:GetPlayers() do
			table.insert(self.connections, plr:GetAttributeChangedSignal('TeamId'):Connect(function()
				self:sendTablist()
			end))
		end
	end
	
	function handler:sendTablist()
		local data = {}
		for _, plr in playersService:GetPlayers() do
			table.insert(data, {
				Name = plr.Name,
				UserId = plr.UserId,
				isLocal = plr == lplr,
				Prefix = lplr:GetAttribute('TeamId') ~= plr:GetAttribute('TeamId') and '/c/c' or '/c/a',
				Suffix = ''
			})
		end
	
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
	
	local function parsePositions(v, func)
		if v:IsA('Part') then
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
	end
	
	function handler:start()
		local mapLoaded = false
	
		self.connections = {
			workspace.BlockContainer.DescendantAdded:Connect(function(v)
				parsePositions(v, function(pos)
					self.blocks[pos // BLOCK_SIZE] = v
					self:write(types.blocks[v.Name] or 1, pos // BLOCK_SIZE, v, mapLoaded)
				end)
			end),
			workspace.BlockContainer.DescendantRemoving:Connect(function(v)
				parsePositions(v, function(pos)
					if self.blocks[pos // BLOCK_SIZE] == v then
						self.blocks[pos // BLOCK_SIZE] = nil
						self:write(0, pos // BLOCK_SIZE, v, mapLoaded)
					end
				end)
			end)
		}
	
		for _, v in workspace.BlockContainer:GetDescendants() do
			parsePositions(v, function(pos)
				self.blocks[pos // BLOCK_SIZE] = v
				self:write(types.blocks[v.Name] or 1, pos // BLOCK_SIZE, v)
			end)
		end
	
		task.spawn(function()
			local tag = game.PlaceId == 8951451142 and 'generator' or 'block:chest'
			if #collectionService:GetTagged(tag) <= 0 then
				collectionService:GetInstanceAddedSignal(tag):Wait()
				task.wait(0.4)
			end
	
			mapLoaded = true
		end)
	
		table.insert(self.connections, debug.getupvalue(debug.getupvalue(skywars.Remotes[remotes['BlockController:onStart']].connect, 1).fireClient, 1).OnClientEvent:Connect(function(...)
			local pos = ...
			if not self.blocks[pos // BLOCK_SIZE] then
				self:write(0, pos // BLOCK_SIZE, nil, mapLoaded)
			end
		end))
	
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
			if data.face ~= -1 then
				local sourceBlock = self.blocks[(data.pos - Vector3.new(0, 128, 0))]
				if sourceBlock and sourceBlock.Parent:HasTag('block:chest') then
					skywars.ChestController:openChest(sourceBlock.Parent)
					return
				end
	
				local placePos = ((data.pos - Vector3.new(0, 128, 0)) + NORMALS[data.face]) * BLOCK_SIZE
				local store = skywars.Store:getState()
				local equipped = store.Inventory.Contents[store.ActiveSlot]
				local equipData = equipped and skywars.ItemMeta[equipped.Type]
	
				if equipData and (equipData.Rewrite or equipData.Block) then
					if skywars.BlockUtil.canPlace(placePos) then
						local prediction = skywars.InventoryController:registerItemPrediction(equipData.Name, -1)
						if prediction then
							skywars.Remotes[remotes.placeBlock]:fire(placePos, 0, prediction)
						else
							self:write(0, placePos // BLOCK_SIZE, nil, mapLoaded)
						end
					else
						self:write(0, placePos // BLOCK_SIZE, nil, mapLoaded)
					end
				end
	
				setthreadidentity(8)
			end
		end
	
		tlayer.listeners.dig = function(data)
			local breakPos = (data.pos - Vector3.new(0, 128, 0))
			if data.status == 0 then
				self.breakPos = breakPos * BLOCK_SIZE
			elseif data.status < 3 then
				if data.status == 2 and self.blocks[breakPos] then
					self:write(types.blocks[self.blocks[breakPos].Name] or 1, breakPos, self.blocks[breakPos], mapLoaded)
				end
	
				self.breakPos = nil
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