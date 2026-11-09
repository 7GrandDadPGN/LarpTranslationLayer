const Handler = require('../handler.js');
const packets = require('../../packets/init.js');
const Chunk = require('prismarine-chunk')('1.8.9');
const ProxyChunk = require('../../../../base/translation/classes/chunk.js');
const Vec3 = require('vec3');
const viewDistance = 7,
	CELL_VOLUME = 16 * 16 * 16;
let client, entity, gui, cSocket;
let MCHandler;

let lightData = new Chunk();
for (let x = 0; x < 16; x++) {
	for (let z = 0; z < 16; z++) {
		for (let skyY = 0; skyY < 256; skyY++) {
			lightData.setSkyLight(new Vec3(x, skyY, z), 15);
		}
	}
}
lightData = lightData.dump();

function getBlockIndex(x, y, z) {
	return ((y & 15) << 8) | ((z & 15) << 4) | (x & 15);
}

const self = class WorldHandler extends Handler {
	createChunk(packet) {
		const chunk = new Chunk();
		chunk.load(lightData);

		if (packet.cells.length <= 0) {
			return chunk;
		}

		for (const cell of packet.cells) {
			const array = cell.bitArray;
			if (!array) continue;
			for (let x = 0; x < 16; x++) {
				for (let y = 0; y < 16; y++) {
					for (let z = 0; z < 16; z++) {
						const offset = array[getBlockIndex(x, y, z)];
						if (offset == 0) continue;
						const blockdata = packet.palette[offset - 1],
							vec = new Vec3(x, cell.y + y, z);
						chunk.setBlockType(vec, blockdata >> 4);
						chunk.setBlockData(vec, blockdata & 15);
					}
				}
			}
		}

		return chunk;
	}
	roblox(socket) {
		cSocket = socket;

		MCHandler.world.requestCallback = function (chunk) {
			socket.send(
				packets.CLIENT.chunk({
					x: chunk[0],
					z: chunk[1]
				})
			);
		};

		socket.on('chunk', (packet) => {
			const chunk = MCHandler.world.addChunk(new ProxyChunk(packet.x, packet.z, this.createChunk(packet)));
			chunk.load();
		});

		socket.on('remove_chunk', (packet) => {
			MCHandler.world.removeChunk(packet.x, packet.z);
		});

		socket.on('block_update', (packet) => {
			let blockData = [packet.type >> 4, packet.type & 15];
			if (blockData[1] == 0) {
				blockData = blockData[0];
			}

			MCHandler.world.setBlock(packet.location, blockData);
		});

		socket.on('play_sound', (packet) => client.write('named_sound_effect', packet));
	}
	minecraft(mcClient) {
		client = mcClient;

		client.on('block_place', (packet) => {
			if (MCHandler.world == undefined) return;
			cSocket.send(packets.CLIENT.place(packet));
		});

		client.on('block_dig', (packet) => {
			if (MCHandler.world == undefined) return;
			cSocket.send(packets.CLIENT.dig(packet));
		});
	}
	cleanup(requeue) {
		client = requeue ? client : undefined;
		this.breaking = false;
	}
	obtainHandlers(handlers, mchandler) {
		entity = handlers.entity;
		gui = handlers.gui;
		MCHandler = mchandler;
	}
};

module.exports = new self();
