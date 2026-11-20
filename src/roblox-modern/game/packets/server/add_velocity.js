const Packet = require('../packet.js');

module.exports = class AddVelocityPacket extends Packet {
	name = 'add_velocity';
	decode(data) {
		return {
			x: data.readDoubleLE(1),
			y: data.readDoubleLE(9),
			z: data.readDoubleLE(17)
		};
	}
};
