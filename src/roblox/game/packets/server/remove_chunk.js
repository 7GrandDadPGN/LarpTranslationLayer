const Packet = require('../packet.js');

module.exports = class RemoveChunkPacket extends Packet {
	name = 'remove_chunk'
	decode(data) {
		return {x: data.readInt32LE(1), z : data.readInt32LE(5)};
	}
};
