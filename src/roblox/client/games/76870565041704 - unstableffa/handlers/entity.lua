local BLOCK_SIZE = 3
local ATTACK_SOUNDS = {
	crit = 'entity.player.attack.crit',
	knockback = 'entity.player.attack.knockback',
	nodamage = 'entity.player.attack.nodamage',
	strong = 'entity.player.attack.strong',
	sweep = 'entity.player.attack.sweep',
	weak = 'entity.player.attack.weak',
	lunge = 'item.spear.lunge_1',
	jabMiss = 'item.spear.use',
	smash = 'item.mace.smash_ground',
	smashHeavy = 'item.mace.smash_ground_heavy',
	smashAir = 'item.mace.smash_air',
	spearCharge = "item.spear.attack"
}

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
		replicatedStorage.MC.Remotes.Event.OnClientEvent:Connect(function(event, data)
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
							pitch = (math.random() - math.random()) * 0.2 + 1
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
					elseif data.kind == 'windThrow' then
						tlayer:send('play_sound', {
							sound = 'entity.wind_charge.throw',
							pos = self:convertPosition(entity.RootPart.Position, entity, true),
							volume = 0.5,
							pitch = 0.4 / (math.random() * 0.4 + 0.8)
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
							pitch = 1
						})
					end
				elseif data.kind == 'wind' then
					tlayer:send('play_sound', {
						sound = 'entity.wind_charge.wind_burst',
						pos = data.pos + Vector3.new(0, 128, 0),
						volume = 1,
						pitch = 1
					})
				elseif data.kind == 'killSound' and lplr.Character and data.killer == lplr.Character:GetAttribute('EntityId') then
					handlers.misc:playLocalSound('entity.wither.spawn')
				end
			end
		end)
	}

	local snapshot
	local startUse
	local didMove

	for _, temp in unstable.Controller.beforeTick do
		if debug.info(temp, 's'):find('Hands') then
			local func = debug.getupvalue(temp, 6)
			if debug.info(func, 'n') == 'attack' then
				snapshot = debug.getupvalue(debug.getupvalue(temp, 6), 15)
			else
				startUse = debug.getupvalue(temp, 6)
			end
		end
	end

	for _, bind in getrendersteppedlist() do
		if bind.Name == 'MCController' then
			self.aimState = debug.getupvalue(bind.Function, 1)
			self.target = bind.Function
			self.tickfunc = debug.getupvalue(self.target, 8)
			self.old = debug.getupvalue(self.tickfunc, 18)
			debug.setupvalue(self.target, 8, function() end)
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
			--attack(entity.State, (localState.position + Vector3.new(0, 1.62, 0)):Max(entity.State.position - Vector3.new(0.4, -0.1, 0.4)):Min(entity.State.position + Vector3.new(0.4, 1.9, 0.4)))
			setthreadidentity(8)
		end
	end

	tlayer.listeners.arm_animation = function()
		firePacket({a = 'swing'})
	end

	tlayer.listeners.use_item = function(data)
		task.spawn(startUse)
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
		debug.setupvalue(self.target, 8, self.tickfunc)
		self.target = nil
		self.tickfunc = nil
		self.old = nil
	end

	if self.windhook then
		restorefunction(unstable.Controller.scheduleBurst)
		self.windhook = nil
	end

	self.botId = -1
	self.sneaking = false
	self.sprinting = false
	self.aimState = nil
	table.clear(self.connections)
	table.clear(self.entities)
	table.clear(self.threads)
	table.clear(self.effects)
end

function handler:tick()
	for _, entity in self.entities do
		local y, x = entity.Head.CFrame:ToEulerAnglesYXZ()
		local pos = self:convertPosition(entity.RootPart.Position, entity, true)

		tlayer:send('entity_move', {
			id = entity.Id,
			yaw = (math.deg(x * -1) - 180) % 360,
			pitch = math.deg(y * -1),
			pos = pos
		})

		if (entity.Using == 'eat' or entity.Using == 'drink') and (os.clock() - entity.SoundTimer) > 0.2 then
			tlayer:send('play_sound', {
				sound = 'entity.generic.'..entity.Using,
				pos = pos,
				volume = entity.Using == 'eat' and (math.random() > 0.5 and 0.5 or 1) or 0.5,
				pitch = entity.Using == 'eat' and 1 + (math.random() - math.random()) * 0.2 or 0.9 + math.random() * 0.1
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

				table.insert(entity.Connections, char:GetAttributeChangedSignal('Gliding'):Connect(function()
					tlayer:send('entity_state', {
						id = entity.Id,
						flag = 7,
						state = char:GetAttribute('Gliding') or false
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
				table.insert(entity.Connections, lplr:GetAttributeChangedSignal('Effects'):Connect(function()
					self:processEffects()
				end))

				handlers.misc:replicateXP()
				entity.gliding = char:GetAttribute('Gliding') or false
				self.character = entity
				self:processEffects()
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
	local decoded = httpService:JSONDecode(armor)
	for i, v in {'head', 'chest', 'legs', 'feet'} do
		self:updateArmor(id, i, decoded[v])
	end
end

function handler:updateArmor(id, slot, item)
	local decoded = type(item) ~= 'string' and item or httpService:JSONDecode(item)
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