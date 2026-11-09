const Packet = require('../packet.js');

module.exports = class EntityStatePacket extends Packet {
	name = 'entity_state'
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			flag: data.readUInt8(9),
			state: data.readUInt8(10) == 1
		};
	}
};