const Packet = require('../packet.js');
const mcData = require('minecraft-data')('1.21.11');

module.exports = class PlaySoundPacket extends Packet {
	name = 'play_sound';
	decode(data) {
		const strLength = data.readUInt8(1);

		return {
			sound: {
				soundId: (mcData.soundsByName[data.toString('utf8', 2, strLength + 2)] || { id: 1 }).id - 1
			},
			soundCategory: 'master',
			x: data.readInt32LE(3 + strLength),
			y: data.readInt32LE(7 + strLength),
			z: data.readInt32LE(11 + strLength),
			volume: data.readFloatLE(15 + strLength),
			pitch: data.readFloatLE(19 + strLength),
			seed: [Math.random() * 1000000, Math.random() * 1000000]
		};
	}
};
