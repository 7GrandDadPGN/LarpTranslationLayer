const Projectile = require('./projectile.js');

module.exports = class FireworkRocketEntity extends Projectile {
	typeId = 53;
	constructor(index) {
		super(index);
		Object.assign(this.dataWatcher.data, {
			8: { key: 8, value: { itemCount: 1, itemId: 1242, components: [], removedComponents: [] }, type: 'item_stack' },
			9: { key: 9, value: undefined, type: 'optional_unsigned_int' },
			10: { key: 10, value: false, type: 'boolean' }
		});
	}
};
