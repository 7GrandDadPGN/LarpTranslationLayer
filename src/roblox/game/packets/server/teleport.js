const Packet = require('../packet.js');

module.exports = class TeleportPacket extends Packet {
	name = 'teleport';
	decode(data) {
		return {
			x: data.readDoubleLE(1),
			y: data.readDoubleLE(9),
			z: data.readDoubleLE(17)
		};
	}
};
