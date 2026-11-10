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
		local boop, target = ...
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

			if killer == lplr then
				handlers.misc:playLocalSound('random.orb')
			end
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