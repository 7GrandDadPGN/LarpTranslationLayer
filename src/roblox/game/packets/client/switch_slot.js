const Packet = require('../packet.js');

module.exports = class SwitchSlotPacket extends Packet {
	name = 'switch_slot'
	encode(data) {
		const buf = Buffer.alloc(2);
		buf.writeUInt8(data.slotId, 1);
		return buf;
	}
};