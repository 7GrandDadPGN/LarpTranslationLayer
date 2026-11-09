const Packet = require('../packet.js');

module.exports = class EntityAbsorptionPacket extends Packet {
	name = 'entity_absorption'
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			amount: data.readFloatLE(9)
		};
	}
};