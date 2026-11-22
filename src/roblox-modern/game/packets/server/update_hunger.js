const Packet = require('../packet.js');

module.exports = class UpdateHungerPacket extends Packet {
	name = 'update_hunger';
	decode(data) {
		return {
			hunger: data.readFloatLE(1),
			saturation: data.readFloatLE(5)
		};
	}
};
