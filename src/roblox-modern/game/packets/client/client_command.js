const Packet = require('../packet.js');
const ENUMS = {
	perform_respawn: 0,
	request_stats: 1
};

module.exports = class ClientCommandPacket extends Packet {
	name = 'client_command';
	encode(data) {
		const buf = Buffer.alloc(2);
		buf.writeInt8(ENUMS[data.actionId] ?? -1, 1);
		return buf;
	}
};
