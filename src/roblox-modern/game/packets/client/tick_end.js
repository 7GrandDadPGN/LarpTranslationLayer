const Packet = require('../packet.js');

module.exports = class TickEndPacket extends Packet {
	name = 'tick_end';
	encode(data) {
		return Buffer.alloc(1);
	}
};
