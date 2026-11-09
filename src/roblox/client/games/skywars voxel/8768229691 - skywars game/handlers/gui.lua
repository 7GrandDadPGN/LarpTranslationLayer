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