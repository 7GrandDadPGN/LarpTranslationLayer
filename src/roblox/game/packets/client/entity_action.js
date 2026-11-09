const Packet = require('../packet.js');

module.exports = class EntityActionPacket extends Packet {
	name = 'entity_action'
	encode(data) {
		const buf = Buffer.alloc(2);
		buf.writeInt8(data.actionId, 1);
		return buf;
	}
};