const Packet = require('../packet.js');

module.exports = class ArmAnimationPacket extends Packet {
	name = 'arm_animation'
	encode(data) {
		return Buffer.alloc(1);
	}
};