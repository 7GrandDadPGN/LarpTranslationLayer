const Packet = require('../packet.js');

module.exports = class ReconnectPacket extends Packet {
	name = 'reconnect';
	decode(data) {
		return {};
	}
};
