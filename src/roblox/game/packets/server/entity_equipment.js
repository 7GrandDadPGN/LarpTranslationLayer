const Packet = require('../packet.js');
const { createItem } = require('../../utils.js');

module.exports = class EntityEquipmentPacket extends Packet {
	name = 'entity_equipment';
	decode(data) {
		const id = data.readUInt32LE(10);
		return {
			id: data.readDoubleLE(1),
			slot: data.readUInt8(9),
			item: id != 0 ? createItem({ id: id >> 16, damage: id & 65535 }, data.readInt8(14)) : { blockId: -1 }
		};
	}
};
