const Packet = require('../packet.js');
const { readItem } = require('../../utils.js');

module.exports = class WindowItemsPacket extends Packet {
	name = 'window_items';
	decode(data) {
		let slots = [];
		let offset = 3;

		for (let i = 0; i < data.readUInt8(2); i++) {
			const [item, newOffset] = readItem(data, offset);
			offset = newOffset;
			slots.push(item);
		}

		return {
			windowId: data.readUInt8(1),
			slots: slots
		};
	}
};
