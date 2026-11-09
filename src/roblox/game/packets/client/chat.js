const Packet = require('../packet.js');

module.exports = class ChatPacket extends Packet {
	name = 'chat'
	encode(data) {
		const buf = Buffer.alloc(5 + data.message.length);
		buf.writeUInt32LE(data.message.length, 1);
		buf.write(data.message, 5);
		return buf;
	}
};