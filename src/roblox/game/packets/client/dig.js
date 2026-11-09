const Packet = require('../packet.js');

module.exports = class DigPacket extends Packet {
	name = 'dig'
	encode(data) {
		const buf = Buffer.alloc(15);
		buf.writeInt8(data.status, 1);
		buf.writeInt32LE(data.location.x, 2);
		buf.writeInt32LE(data.location.y, 6);
		buf.writeInt32LE(data.location.z, 10);
		buf.writeInt8(data.face, 14);
		return buf;
	}
};