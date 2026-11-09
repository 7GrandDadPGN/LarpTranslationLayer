const Packet = require('../packet.js');

module.exports = class BlockUpdatePacket extends Packet {
	name = 'block_update'
	decode(data) {
		return {
			type: data.readUint16LE(1),
			location: {
				x: data.readInt32LE(3),
				y: data.readInt32LE(7),
				z: data.readInt32LE(11)
			}
		};
	}
};