const Packet = require('../packet.js');
let offset = 0;

function readString(buf) {
	const str = buf.toString('utf8', offset + 1, offset + 1 + buf.readUInt8(offset));
	offset += 1 + buf.readUInt8(offset);
	return str;
}

module.exports = class ScoreboardPacket extends Packet {
	name = 'scoreboard'
	decode(data) {
		let lines = [];
		offset = 2;

		for (let i = 0; i < data.readUInt8(1); i++) {
			lines.push(readString(data));
		}

		return {lines: lines, title: readString(data)};
	}
};