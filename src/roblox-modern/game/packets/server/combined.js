const Packet = require('../packet.js');

module.exports = class CombinedPacket extends Packet {
	name = 'combined';
	decode(data) {
		const packets = [];
		let offset = 3;

		for (let i = 0; i < data.readUInt16LE(1); i++) {
			const length = data.readUInt16LE(offset);
			packets.push(data.slice(offset + 2, offset + length + 2));
			offset += length + 2;
		}

		return packets;
	}
};
