const Packet = require('../packet.js');

module.exports = class OpenWindowPacket extends Packet {
	name = 'open_window'
	decode(data) {
		return {
			windowId: data.readUInt8(1),
			inventoryType: data.toString('utf8', 4, 4 + data.readUInt8(3)),
			windowTitle: JSON.stringify({translate: 'container.chest'}),
			slotCount: data.readUInt8(2)
		};
	}
};