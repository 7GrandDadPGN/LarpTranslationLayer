const Packet = require('../packet.js');

module.exports = class ChunkPacket extends Packet {
	name = 'chunk'
	encode(data) {
		const buf = Buffer.alloc(9);
		buf.writeInt32LE(data.x, 1);
		buf.writeInt32LE(data.z, 5);
		return buf;
	}
};