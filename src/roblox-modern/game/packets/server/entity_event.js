const Packet = require('../packet.js');

module.exports = class EntityEventPacket extends Packet {
	name = 'entity_event';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			event: data.readUInt8(9)
		};
	}
};
