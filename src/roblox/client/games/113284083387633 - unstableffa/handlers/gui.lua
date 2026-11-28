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