const Packet = require('../packet.js');

module.exports = class UseItemPacket extends Packet {
	name = 'use_item';
	encode(data) {
		const buf = Buffer.alloc(2);
		buf.writeUInt8(data.hand, 1);
		return buf;
	}
};
