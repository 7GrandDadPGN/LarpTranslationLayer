const Packet = require('../packet.js');
const { createItem } = require('../../utils.js');

module.exports = class SetSlotPacket extends Packet {
	name = 'set_slot';
	decode(data) {
		const id = data.readUInt32LE(3);

		return {
			windowId: data.readUInt8(1),
			slot: data.readUInt8(2),
			item: id != 0 ? createItem({ id: id >> 16, damage: id & 65535 }, data.readInt8(7)) : { blockId: -1 }
		};
	}
};
