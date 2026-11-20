const Handler = require('./../handler.js');
const packets = require('../../packets/init.js');
let client, entity, cSocket, MCHandler;

const self = class GuiHandler extends Handler {
	roblox(socket) {
		cSocket = socket;

		socket.on('window_items', (packet) => {
			client.write('window_items', {
				windowId: packet.windowId,
				stateId: 0,
				items: packet.slots,
				carriedItem: { itemCount: 0 }
			});
		});

		socket.on('set_slot', (packet) => {
			client.write('set_player_inventory', {
				slotId: packet.slot,
				item: packet.item
			});
		});

		socket.on('open_window', (packet) => {
			client.write('open_window', {
				entityId: MCHandler.local.minecraftId,
				windowId: packet.windowId,
				windowTitle: packet.windowTitle,
				inventoryType: packet.inventoryType,
				slotCount: packet.slotCount
			});
		});
	}
	minecraft(mcClient) {
		client = mcClient;

		client.on('window_click', (packet) =>
			cSocket.send(
				packets.CLIENT.click_slot({
					windowId: packet.windowId,
					slot: Number.parseInt(packet.slot),
					mode: packet.mode,
					mouseButton: packet.mouseButton
				})
			)
		);

		client.on('close_window', () => cSocket.send(packets.CLIENT.close_window()));
	}
	cleanup(requeue) {
		client = requeue ? client : undefined;
		this.currentlyOpen = '';
		this.ignorePacket = 0;
	}
	obtainHandlers(handlers, mchandler) {
		entity = handlers.entity;
		MCHandler = mchandler;
	}
};

module.exports = new self();
