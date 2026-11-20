const Packet = require('../packet.js');

module.exports = class DisconnectPacket extends Packet {
	name = 'disconnect';
	encode() {
		return Buffer.alloc(1);
	}
};
