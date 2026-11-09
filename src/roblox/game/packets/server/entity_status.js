const Packet = require('../packet.js');

module.exports = class EntityStatusPacket extends Packet {
	name = 'entity_status';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			status: data.readUInt8(9)
		};
	}
};
