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