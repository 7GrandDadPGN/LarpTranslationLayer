const Packet = require('../packet.js');

module.exports = class AttackPacket extends Packet {
	name = 'attack';
	encode(data) {
		const buf = Buffer.alloc(9);
		buf.writeDoubleLE(data.id, 1);
		return buf;
	}
};
