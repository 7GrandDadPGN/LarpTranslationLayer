const Packet = require('../packet.js');

module.exports = class HeldItemSlot extends Packet {
	name = 'held_item_slot';
	decode(data) {
		return {
			slot: data.readInt8(1)
		};
	}
};
