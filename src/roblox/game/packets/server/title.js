const Packet = require('../packet.js');
let offset = 0;

function readString(buf) {
	const str = buf.toString('utf8', offset + 1, offset + 1 + buf.readUInt8(offset));
	offset += 1 + buf.readUInt8(offset);
	return str;
}

module.exports = class TitlePacket extends Packet {
	name = 'title'
	decode(data) {
		offset = 2;

		const text = readString(data);
		return {
			action: data.readUInt8(1),
			text: text,
			fadeIn: data.readInt32LE(offset),
			stay: data.readInt32LE(offset + 4),
			fadeOut: data.readInt32LE(offset + 8)
		};
	}
};