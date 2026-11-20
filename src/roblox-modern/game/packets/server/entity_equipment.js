const Packet = require('../packet.js');
const { readItem } = require('../../utils.js');

module.exports = class EntityEquipmentPacket extends Packet {
	name = 'entity_equipment';
	decode(data) {
		const [item] = readItem(data, 10);
		return {
			id: data.readDoubleLE(1),
			slot: data.readUInt8(9),
			item: item
		};
	}
};
