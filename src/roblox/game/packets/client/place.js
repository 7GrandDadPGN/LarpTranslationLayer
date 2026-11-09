const Packet = require('../packet.js');

module.exports = class PlacePacket extends Packet {
	name = 'place'
	encode(data) {
		const buf = Buffer.alloc(14);
		buf.writeInt32LE(data.location.x, 1);
		buf.writeInt32LE(data.location.y, 5);
		buf.writeInt32LE(data.location.z, 9);
		buf.writeInt8(data.direction, 13);
		return buf;
	}
};