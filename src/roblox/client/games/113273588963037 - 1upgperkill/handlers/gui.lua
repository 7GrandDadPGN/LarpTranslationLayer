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