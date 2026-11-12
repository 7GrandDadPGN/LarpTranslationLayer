local ARMOR_TABLE = {'head', 'chest', 'legs', 'feet'}
local handler = {
	Name = 'gui',
	connections = {},
	isOpen = false
}

function handler:start()
	self.old = searchFor(slop.InventoryController.start, 'onInventory')

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

	for slot, item in debug.getupvalue(debug.getupvalue(slop.InventoryController.start, 6), 2) do
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