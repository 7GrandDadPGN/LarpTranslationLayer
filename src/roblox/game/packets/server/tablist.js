const Packet = require('../packet.js');
let offset = 0;

function readString(buf) {
	const str = buf.toString('utf8', offset + 1, offset + 1 + buf.readUInt8(offset));
	offset += 1 + buf.readUInt8(offset);
	return str;
}

module.exports = class TablistPacket extends Packet {
	name = 'tablist'
	decode(data) {
		let players = [];
		offset = 2;

		for (let i = 0; i < data.readUInt8(1); i++) {
			const player = {};
			player.id = data.readDoubleLE(offset);
			offset += 8;
			player.isLocal = data.readUInt8(offset) > 0;
			offset += 1;
			player.name = readString(data);
			player.prefix = readString(data);
			player.suffix = readString(data);
			players.push(player);
		}

		return {players: players};
	}
};