const handlers = require('./game/handlers/init.js');
const packets = require('./game/packets/init.js');
const mcData = require('minecraft-data')('1.21.11');
const Chunk = require('prismarine-chunk')('1.21.11');
const Vec3 = require('vec3');
const mc = require('minecraft-protocol');
const ws = require('ws');
const MCHandler = new (require('../base-modern/index.js'))();

const server = mc.createServer({
	'online-mode': false,
	motd: '\u00a76' + ' '.repeat(12) + 'Roblox Translation Layer \u00a7c[1.21.11]\n\u00a7a' + ' '.repeat(21) + 'Made by 7GrandDad',
	favicon: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAPXSURBVHhe5Zs/qBxVGMW/80kSTJ6CikYbH9hoCOI/UAmBiKVFGu2sFATBQhDRyt5CESSghYiVjcTGgFVCKtFCkAiJnZEHKgQDJhieT3OOxduVu9/O7NyZnZ03O/Pr5nz37dx77vnuvtl9z6wBkkTyOsknY20UqACS30q6I44dHJL2x8WX8G782UFA8se40ipIbpN8Or5WH0AUqpCkqNVF0g9mdsLdr8Va13gUugDAowD+TBLyQRzTS0gencn2CiB5U9LxeO9VUasFSP4K4L6orxJJl8zsuLtfjbU2qNUCXS/edu95BMAfSUI+imOWoVYC1MIB2DaSnnf3L6OeS3YCSJ6MWh8AcDpJxxbJ2+OYRWQngOQ1ALdFvc9I+szdX4p6SrYBfYx/XSS94O6nU21UBqRIuuLu92SdASRfj9q6A+Buy03A0Hbfdtd0wd0fGbMB97v7VqUBkvaZ2U7U1x0AsJzfAyR9GLUhkZOAIcb/K3c/aSM2YMPd/7IqA0geALAd9XVn2v+WcQZ8E4V1RxLT64UGAHg8akuwKemwpO9ioWM+Ti8WtkCb/Z/GbgrJZ83sCwB3xtqqiPMoTYCkg1FrSpmR7n7O3e/CBEnvlI1dFXO7MoXkvwBuiXoTJF1096NRX8Tkuf5rAMdirSmS6O4zayo1oM2diLGrQ5vzkPSKu3+SaqUTa/PGfTGgaB6FZ8DkcBoFhQYAOBu1pkj6NGq5kGxzHoUPdHORsA5il0ub8zCzIwB+imLh5Nq8cV8MKJvHXAuQPBW1ITNnAIDXotYUSY2/SyD5T9SaIqn0W+i5WHQRuxy6msdcAsbGjAEkL6XXy0LyBsnNqFdB8rGorYqYgAfD9VIAuBXAZU0geS6OKeH7KDRF0pmopcz0Rpt9l4OkN939/QK9tXks6n9LDZB0r5n9NlvuDknbZvaEu1/cEwNIXgewMVtef6oM+P8MGOLiJb0ctUjaAq3Fri9U7b5NE0DyuVgYC7BdA/4GsD8W153sBAxx8ZIeiloRsBH3v5mZk3wrimMCJHcA7IuFdUbSz+7+QNSLcDPbiuIAeCoKZcz0CclNAJdTbR3J7X+LT4Pu/gsSJL2d1odItlO2m5ALAB6Oep9I//ojh1oGpOz10+MCDgG4EcUy4gci2QD4PbTLq3HMXlBn8bZMAqqQdN7MTkR91aDGAWjLJKAKAM8k6Tgo6WYc0zaS3otaLyH54vRzwpZZ2YauFJJn4kqaEF83h1r90gWT/0y9CuBQrC1C0o67H4h6Fb2LDIAdd99Izo/c9/Q3ojBISH4eo6+G8V97JIHklWUM+A/KVl38+AsCWQAAAABJRU5ErkJggg==',
	maxPlayers: 1,
	keepAlive: true,
	version: '1.21.11'
});

const wsServer = new ws.Server({
	port: 6874,
	skipUTF8Validation: true,
	handleProtocols: (protocols, client) => {
		console.log(protocols, client);
	}
});

let connected, skipKick, didTeleport, cSocket, mClient;

function cleanup(teleport) {
	if (cSocket != undefined) {
		for (const name of cSocket.eventNames()) {
			if (name != 'close' && name != 'message' && name != 'combined' && name != 'reconnect' && name != 'login') {
				cSocket.removeAllListeners(name);
			}
		}
	}

	connected = teleport ?? false;
	Object.values(handlers).forEach((handler) => handler.cleanup(teleport));
}

function init() {
	if (cSocket != undefined && mClient != undefined) {
		MCHandler.createWorld(mClient, !didTeleport, 2, 0);
		Object.values(handlers).forEach((handler) => handler.roblox(cSocket));
		cSocket.send(packets.CLIENT.login());
	}
}

server.on('playerJoin', async function (client) {
	didTeleport = false;

	if (connected) {
		client.end('A player is already logged in!');
		return;
	}

	if (client.username == undefined || client.uuid == undefined) {
		client.end('Missing Username / UUID, please ensure you are using a valid cracked Minecraft account!');
		return;
	}

	if (client.protocolVersion != 774) {
		console.log(`\x1b[33m[*] Incorrect client version, Please use Minecraft 1.8.9!\x1b[0m`);
		return;
	}

	if (cSocket == undefined) {
		//client.end('Missing game client, please make sure the layer is running on the roblox side!');
		client.write('login', {
			...mcData.loginPacket,
			entityId: client.id,
			isHardcore: false,
			gameMode: 0,
			previousGameMode: 1,
			worldName: 'minecraft:overworld',
			hashedSeed: [0, 0],
			maxPlayers: 1,
			viewDistance: 10,
			reducedDebugInfo: false,
			enableRespawnScreen: true,
			isDebug: false,
			isFlat: false
		});

		const chunk = new Chunk();
		for (let x = 0; x < 16; x++) {
			for (let z = 0; z < 16; z++) {
				chunk.setBlockType(new Vec3(x, 100, z), mcData.blocksByName.grass_block.id);
				chunk.setBlockData(new Vec3(x, 100, z), 1);
				for (let y = 0; y < 255; y++) {
					chunk.setSkyLight(new Vec3(x, y, z), 15);
				}
			}
		}

		client.write('player_info', {
			action: { add_player: true, update_listed: true, update_list_order: true },
			data: [
				{
					uuid: client.uuid,
					player: {
						name: client.username,
						properties: []
					},
					listed: 10,
					latency: 11,
					gamemode: 1,
					listPriority: 10,
					displayName: 'aaa',
					showHat: true
				}
			]
		});

		client.write('game_state_change', {
			reason: 13,
			gamemode: 0
		});

		for (let x = -7; x < 7; x++) {
			for (let z = -7; z < 7; z++) {
				client.write('map_chunk', {
					x: x,
					z: z,
					groundUp: true,
					biomes: chunk.dumpBiomes !== undefined ? chunk.dumpBiomes() : undefined,
					heightmaps: {
						type: 'compound',
						name: '',
						value: {} // Client will accept fake heightmap
					},
					bitMap: chunk.getMask(),
					chunkData: chunk.dump(),
					blockEntities: [],
					...chunk.dumpLight()
				});
			}
		}

		client.write('position', {
			teleportId: 1,
			x: 15,
			y: 101,
			z: 15,
			yaw: 137,
			pitch: 0,
			flags: 0x00
		});
		return;
	}

	client.on('end', function () {
		MCHandler.deleteWorld();
		cleanup();

		mClient = undefined;
		if (cSocket != undefined) {
			cSocket.send(packets.CLIENT.disconnect());
		}
	});

	mClient = client;
	Object.values(handlers).forEach((handler) => handler.minecraft(client));

	init();
	connected = !client.ended;
});

wsServer.on('connection', function (socket) {
	if (cSocket != undefined) {
		console.log('attempted to connect while a socket exists');
		socket.terminate();
		return;
	}

	cSocket = socket;

	socket.on('message', function (data) {
		const packet = packets.SERVER[data.readUInt8(0)];
		if (packet) socket.emit(packet.name, packet.decode(data));
	});

	socket.on('combined', function (packetList) {
		for (const data of packetList) {
			const packet = packets.SERVER[data.readUInt8(0)];
			if (packet) socket.emit(packet.name, packet.decode(data));
		}
	});

	socket.on('login', () => init());
	socket.on('close', function () {
		if (socket == cSocket) {
			cSocket = undefined;

			if (skipKick) {
				skipKick = false;
			} else if (mClient) {
				mClient.end('Disconnected');
			}
		}
	});

	socket.on('reconnect', () => {
		skipKick = true;
		didTeleport = true;
		MCHandler.deleteWorld();
		cleanup(true);
	});
});

Object.values(handlers).forEach((handler) => handler.obtainHandlers(handlers, MCHandler));
console.log('\x1b[33mVersion: 1.0\x1b[0m');
