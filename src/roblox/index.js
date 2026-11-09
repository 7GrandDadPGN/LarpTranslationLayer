const handlers = require('./game/handlers/init.js');
const packets = require('./game/packets/init.js');
const mc = require('minecraft-protocol');
const ws = require('ws');
const MCHandler = new (require('../base/index.js'));

const server = mc.createServer({
	'online-mode': false,
	motd: '\u00a76' + ' '.repeat(14) + 'Roblox Translation Layer \u00a7c[1.8]\n\u00a7a' + ' '.repeat(21) + 'Made by 7GrandDad',
	favicon: '',
	maxPlayers: 1,
	keepAlive: true,
	version: '1.8.9'
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
};

function init() {
	if (cSocket != undefined && mClient != undefined) {
		MCHandler.createWorld(mClient, !didTeleport, 2, 0);
		Object.values(handlers).forEach((handler) => handler.roblox(cSocket));
		cSocket.send(packets.CLIENT.login());
	}
};

server.on('playerJoin', async function(client) {
	didTeleport = false;

	if (connected) {
		client.end('A player is already logged in!');
		return;
	}

	if (client.username == undefined || client.uuid == undefined) {
		client.end('Missing Username / UUID, please ensure you are using a valid cracked Minecraft account!');
		return;
	}

	if (client.protocolVersion != 47) {
		console.log(`\x1b[33m[*] Incorrect client version, Please use Minecraft 1.8.9!\x1b[0m`);
		return;
	}

	if (cSocket == undefined) {
		client.end('Missing game client, please make sure the layer is running on the roblox side!');
		return;
	}

	client.on('end', function() {
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

wsServer.on('connection', function(socket) {
	if (cSocket != undefined) {
		console.log('attempted to connect while a socket exists');
		socket.terminate();
		return;
	}

	cSocket = socket;

	socket.on('message', function(data) {
		const packet = packets.SERVER[data.readUInt8(0)];
		if (packet) socket.emit(packet.name, packet.decode(data));
	});

	socket.on('combined', function(packetList) {
		for (const data of packetList) {
			const packet = packets.SERVER[data.readUInt8(0)];
			if (packet) socket.emit(packet.name, packet.decode(data));
		}
	});

	socket.on('login', () => init());
	socket.on('close', function() {
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