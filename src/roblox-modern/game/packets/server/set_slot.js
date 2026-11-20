const Packet = require('../packet.js');
const { createItem, readItem } = require('../../utils.js');

module.exports = class SetSlotPacket extends Packet {
	name = 'set_slot';
	decode(data) {
		const [item] = readItem(data, 3);
		return {
			windowId: data.readUInt8(1),
			slot: data.readUInt8(2),
			item: item
		};
	}
};
