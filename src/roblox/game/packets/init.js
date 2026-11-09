const fs = require('fs');

module.exports = {
	CLIENT: fs.readdirSync('./src/roblox/game/packets/client').map(file => new (require('./client/' + file))()),
	SERVER: fs.readdirSync('./src/roblox/game/packets/server').map(file => new (require('./server/' + file))())
};

module.exports.CLIENT = module.exports.CLIENT.sort((a, b) => a.name > b.name ? 1 : -1);
module.exports.SERVER = module.exports.SERVER.sort((a, b) => a.name > b.name ? 1 : -1);
module.exports.CLIENT = Object.fromEntries(module.exports.CLIENT.map((packet, id) => {
	const original = packet.encode;
	return [packet.name, function(...args) {
		const data = original(...args);
		data.writeUInt8(id, 0);
		return data;
	}];
}));