const Packet = require('../packet.js');

module.exports = class EntityEffectPacket extends Packet {
	name = 'entity_effect';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			effectId: data.readUInt8(9),
			amplifier: data.readUInt8(10),
			duration: data.readUInt16LE(11),
			flags: data.readUInt8(13)
		};
	}
};
