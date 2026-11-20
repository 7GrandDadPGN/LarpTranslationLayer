const Packet = require('../packet.js');

module.exports = class EntityVelocityPacket extends Packet {
	name = 'entity_velocity';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			x: data.readDoubleLE(9),
			y: data.readDoubleLE(17),
			z: data.readDoubleLE(25)
		};
	}
};
