const Packet = require('../packet.js');

module.exports = class CloseWindowPacket extends Packet {
	name = 'close_window'
	encode() {
		return Buffer.alloc(1);
	}
};