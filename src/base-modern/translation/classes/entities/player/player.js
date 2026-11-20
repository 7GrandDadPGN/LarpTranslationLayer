const Avatar = require('../living/avatar.js');

module.exports = class Player extends Avatar {
	typeId = 155;
	attributeMap = {
		'generic.attack_speed': {
			key: 'generic.attack_speed',
			value: 4,
			modifiers: []
		},
		'generic.max_health': {
			key: 'generic.max_health',
			value: 20,
			modifiers: []
		},
		'generic.max_absorption': {
			key: 'generic.max_absorption',
			value: 0,
			modifiers: []
		},
		'player.block_interaction_range': {
			key: 'player.block_interaction_range',
			value: 4.5,
			modifiers: []
		},
		'player.entity_interaction_range': {
			key: 'player.entity_interaction_range',
			value: 3,
			modifiers: []
		}
	};
	canSpawn() {
		return super.canSpawn() && (this.world.tablist.players[this.index] != undefined || this.bot != undefined || this == this.world.local);
	}
	constructor(index) {
		super(index);
		Object.assign(this.dataWatcher.data, {
			17: { key: 17, value: 0, type: 'float' },
			18: { key: 18, value: 0, type: 'int' },
			19: { key: 19, value: undefined, type: 'optional_unsigned_int' },
			20: { key: 20, value: undefined, type: 'optional_unsigned_int' }
		});
	}
	getAddEntityPacket() {
		this.uuid = this.world.tablist.uuids[this.index] || this.uuid;
		return super.getAddEntityPacket();
	}
};
