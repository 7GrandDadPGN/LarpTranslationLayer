const Packet = require('../packet.js');

module.exports = class MovePacket extends Packet {
	name = 'move'
	encode(data) {
		const buf = Buffer.alloc(35);
		buf.writeDoubleLE(data.pos.x, 1);
		buf.writeDoubleLE(data.pos.y, 9);
		buf.writeDoubleLE(data.pos.z, 17);
		buf.writeFloatLE(data.yaw, 25);
		buf.writeFloatLE(data.pitch, 29);
		buf.writeUInt8(data.onGround ? 1 : 0, 33);
		return buf;
	}
};