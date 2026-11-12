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