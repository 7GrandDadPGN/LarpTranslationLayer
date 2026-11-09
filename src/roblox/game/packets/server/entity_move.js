const Packet = require('../packet.js');

module.exports = class EntityMovePacket extends Packet {
	name = 'entity_move';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			yaw: data.readFloatLE(9),
			pitch: data.readFloatLE(13),
			pos: {
				x: data.readDoubleLE(17),
				y: data.readDoubleLE(25),
				z: data.readDoubleLE(33)
			}
		};
	}
};
