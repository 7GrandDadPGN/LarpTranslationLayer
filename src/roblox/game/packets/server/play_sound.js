const Packet = require('../packet.js');

module.exports = class PlaySoundPacket extends Packet {
	name = 'play_sound'
	decode(data) {
		const strLength = data.readUInt8(1);
		return {
			soundName: data.toString('utf8', 2, strLength + 2),
			x: data.readInt32LE(3 + strLength),
			y: data.readInt32LE(7 + strLength),
			z: data.readInt32LE(11 + strLength),
			volume: data.readFloatLE(15 + strLength),
			pitch: data.readUInt8(19 + strLength)
		};
	}
};