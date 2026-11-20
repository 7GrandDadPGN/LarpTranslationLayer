const Packet = require('../packet.js');

module.exports = class EntityHurtPacket extends Packet {
	name = 'entity_hurt';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			yaw: data.readFloatLE(9),
			damageType: data.readUInt8(14)
		};
	}
};
