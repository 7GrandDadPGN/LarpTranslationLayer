const Packet = require('../packet.js');

module.exports = class LoginPacket extends Packet {
	name = 'login'
	decode(data) {}
};