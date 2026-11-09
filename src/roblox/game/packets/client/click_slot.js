const Packet = require('../packet.js');

module.exports = class ClickSlotPacket extends Packet {
	name = 'click_slot';
	encode(data) {
		const buf = Buffer.alloc(5);
		buf.writeUInt8(data.windowId, 1);
		buf.writeUInt8(data.slot == -999 ? 255 : data.slot, 2);
		buf.writeUInt8(data.mode, 3);
		buf.writeUInt8(data.mouseButton, 4);
		return buf;
	}
};
