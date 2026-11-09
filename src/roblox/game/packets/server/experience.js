const Packet = require('../packet.js');

module.exports = class ExperiencePacket extends Packet {
	name = 'experience'
	decode(data) {
		return {
			experienceBar: data.readFloatLE(1),
			level: data.readDoubleLE(9),
			totalExperience: data.readDoubleLE(17)
		};
	}
};