const Packet = require('../packet.js');
const { createItem } = require('../../utils.js');

module.exports = class WindowItemsPacket extends Packet {
	name = 'window_items';
	decode(data) {
		let slots = [];

		for (let i = 0; i < data.readUInt8(2); i++) {
			const offset = 3 + i * 5;
			const id = data.readUInt32LE(offset);

			slots.push(id != 0 ? createItem({ id: id >> 16, damage: id & 65535 }, data.readInt8(offset + 4)) : { blockId: -1 });
		}

		return {
			windowId: data.readUInt8(1),
			slots: slots
		};
	}
};
