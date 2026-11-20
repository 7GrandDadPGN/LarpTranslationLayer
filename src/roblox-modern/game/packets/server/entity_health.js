const Packet = require('../packet.js');

module.exports = class EntityHealthPacket extends Packet {
	name = 'entity_health';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			health: data.readFloatLE(9)
		};
	}
};
