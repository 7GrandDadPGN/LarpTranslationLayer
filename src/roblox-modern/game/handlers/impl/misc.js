const Handler = require('./../handler.js');
const { translateText } = require('./../../utils.js');
const packets = require('../../packets/init.js');
let client, entity, connect, cSocket, world;

const self = class ChatHandler extends Handler {
	roblox(socket) {
		cSocket = socket;

		socket.on('chat', (packet) => {
			client.write('system_chat', {
				content: translateText(packet.message),
				isActionBar: false
			});
		});

		socket.on('title', (packet) => {
			client.write('title', {
				action: packet.action,
				text: translateText(packet.text),
				fadeIn: packet.fadeIn,
				stay: packet.stay,
				fadeOut: packet.fadeOut
			});
		});

		socket.on('kick', (packet) => {
			client.end(packet.message);
		});
	}
	minecraft(mcClient) {
		client = mcClient;

		client.on('chat_message', (packet) =>
			cSocket.send(
				packets.CLIENT.chat({
					message: packet.message
				})
			)
		);
	}
	cleanup(requeue) {
		client = requeue ? client : undefined;
	}
	obtainHandlers(handlers, _) {
		entity = handlers.entity;
		world = handlers.world;
	}
};

module.exports = new self();
