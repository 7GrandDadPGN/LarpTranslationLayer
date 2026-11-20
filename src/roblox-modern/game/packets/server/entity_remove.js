const Packet = require('../packet.js');

module.exports = class EntityRemovePacket extends Packet {
	name = 'entity_remove';
	decode(data) {
		return {
			id: data.readDoubleLE(1)
		};
	}
};
