const Packet = require('../packet.js');
const ENUMS = {
	leave_bed: 0,
	start_sprinting: 1,
	stop_sprinting: 2,
	start_horse_jump: 3,
	stop_horse_jump: 4,
	open_vehicle_inventory: 5,
	start_fall_flying: 6,
	start_sneaking: 7,
	stop_sneaking: 8
};

module.exports = class EntityActionPacket extends Packet {
	name = 'entity_action';
	encode(data) {
		const buf = Buffer.alloc(2);
		buf.writeInt8(ENUMS[data.actionId] ?? -1, 1);
		return buf;
	}
};
