const LivingEntity = require('./livingentity.js');

module.exports = class Avatar extends LivingEntity {
	constructor(index) {
		super(index);
		Object.assign(this.dataWatcher.data, {
			15: { key: 15, value: 'right', type: 'humanoid_arm' },
			16: { key: 16, value: 127, type: 'byte' }
		});
	}
};
