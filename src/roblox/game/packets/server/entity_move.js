const Packet = require('../packet.js');

module.exports = class EntityMovePacket extends Packet {
	name = 'entity_move';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			yaw: data.readFloatLE(9),
			pitch: data.readFloatLE(13),
			onGround: data.readUInt8(17) > 0,
			pos: {
				x: data.readDoubleLE(18),
				y: data.readDoubleLE(26),
				z: data.readDoubleLE(34)
			}
		};
	}
};
