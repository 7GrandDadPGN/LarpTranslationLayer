const Packet = require('../packet.js');

module.exports = class KickPacket extends Packet {
	name = 'kick';
	decode(data) {
		const stringSize = data.readUInt32LE(1);
		return {
			message: data.toString('utf8', 5, 5 + stringSize)
		};
	}
};
