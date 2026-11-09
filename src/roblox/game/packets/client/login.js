const Packet = require('../packet.js');

module.exports = class LoginPacket extends Packet {
	name = 'login'
	encode() {
		return Buffer.alloc(1);
	}
};