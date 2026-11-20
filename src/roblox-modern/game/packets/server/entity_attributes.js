const Packet = require('../packet.js');

module.exports = class EntityAttributesPacket extends Packet {
	name = 'entity_attributes';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			attributes: data.toString('utf8', 13, 13 + data.readUInt32LE(9))
		};
	}
};
