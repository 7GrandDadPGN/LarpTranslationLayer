const Packet = require('../packet.js');

module.exports = class ReloadWorldPacket extends Packet {
	name = 'reload_world';
	decode(data) {}
};
