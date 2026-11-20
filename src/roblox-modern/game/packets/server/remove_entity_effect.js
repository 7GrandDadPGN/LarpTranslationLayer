const Packet = require('../packet.js');

module.exports = class RemoveEntityEffectPacket extends Packet {
	name = 'remove_entity_effect';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			effectId: data.readUInt8(9)
		};
	}
};
