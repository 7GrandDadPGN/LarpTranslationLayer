const Packet = require('../packet.js');

module.exports = class EntitySpawnPacket extends Packet {
	name = 'entity_spawn';
	decode(data) {
		return {
			id: data.readDoubleLE(1),
			type: data.readUInt8(9),
			isLocal: data.readUInt8(10) > 0,
			isBot: data.readUInt8(11) > 0,
			yaw: data.readFloatLE(12),
			pitch: data.readFloatLE(16),
			pos: {
				x: data.readDoubleLE(20),
				y: data.readDoubleLE(28),
				z: data.readDoubleLE(36)
			}
		};
	}
};
