const Packet = require('../packet.js');

module.exports = class EntityMetadataPacket extends Packet {
	name = 'entity_metadata';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			metadata: data.toString('utf8', 13, 13 + data.readUInt32LE(9))
		};
	}
};
