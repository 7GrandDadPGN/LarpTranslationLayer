const Handler = require('./../handler.js');
const { translateText } = require('./../../utils.js');
const packets = require('../../packets/init.js');
let client, entity, connect, cSocket, world;

const self = class ChatHandler extends Handler {
	roblox(socket) {
		cSocket = socket;

		socket.on('chat', (packet) => {
			client.write('chat', {
				message: JSON.stringify({
					extra: [translateText(packet.message)],
					text: ''
				}),
				position: 1
			});
		});

		socket.on('title', (packet) => {
			client.write('title', {
				action: packet.action,
				text: JSON.stringify({ text: translateText(packet.text) }),
				fadeIn: packet.fadeIn,
				stay: packet.stay,
				fadeOut: packet.fadeOut
			});
		});
	}
	minecraft(mcClient) {
		client = mcClient;

		client.on('chat', (packet) =>
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
