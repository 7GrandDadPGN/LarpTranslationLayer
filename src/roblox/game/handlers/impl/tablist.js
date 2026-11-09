const Handler = require('./../handler.js');
const { translateText } = require('./../../utils.js');
const { SKINS } = require('./../../types/skins.js');
let client, entity, MCHandler;

const self = class TabListHandler extends Handler {
	processEntry(entry) {
		entry.id = entry.id.toString();
		const tabEntry = MCHandler.tablist.players[entry.id];
		const playerNum = Number.parseInt(entry.id);
		entry.prefix = translateText(entry.prefix);
		entry.suffix = translateText(entry.suffix);

		if (tabEntry != undefined) {
			MCHandler.tablist.updatePing(entry.id, 0);
			MCHandler.tablist.updatePrefix(entry.id, entry.prefix);
			MCHandler.tablist.updateSuffix(entry.id, entry.suffix);
		} else {
			MCHandler.tablist.add(
				entry.id,
				{
					name: (entry.isLocal ? client.username : entry.name).slice(0, 16),
					gamemode: 0,
					ping: 0,
					prefix: entry.prefix,
					suffix: entry.suffix,
					uuid: entry.isLocal ? client.uuid : undefined,
					skin: SKINS[Number.isFinite(playerNum) ? playerNum % SKINS.length : Math.floor(Math.random() * SKINS.length)]
				},
				entry.isLocal
			);
		}
	}
	roblox(socket) {
		socket.on('tablist', (packet) => {
			const exists = [];
			for (const entry of packet.players) {
				this.processEntry(entry);
				exists.push(entry.id);
			}

			for (const id of Object.keys(MCHandler.tablist.players).filter((id) => !exists.includes(id))) {
				MCHandler.tablist.remove(id);
			}

			MCHandler.world.tickEntities();

			client.write('playerlist_header', {
				header: JSON.stringify({ text: '\u00a7bYou are playing on \u00a7aroblox.com' }),
				footer: JSON.stringify({ text: '\u00a76Translation layer made by 7GrandDad' })
			});
		});
	}
	minecraft(mcClient) {
		client = mcClient;
	}
	cleanup(requeue) {
		client = requeue ? client : undefined;
	}
	obtainHandlers(handlers, mchandler) {
		entity = handlers.entity;
		MCHandler = mchandler;
	}
};

module.exports = new self();
