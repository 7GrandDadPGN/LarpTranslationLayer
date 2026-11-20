const Avatar = require('../living/avatar.js');

module.exports = class Player extends Avatar {
	typeId = 155;
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
