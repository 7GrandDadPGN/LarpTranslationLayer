const Packet = require('../packet.js');

module.exports = class EntityAnimationPacket extends Packet {
	name = 'entity_animation';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			animation: data.readUInt8(9)
		};
	}
};
