const Entity = require('../entity.js');

function convertToByte(num) {
	num &= 0xff;
	num = num > 127 ? num - 256 : num;
	return num;
}

module.exports = class LivingEntity extends Entity {
	equipment = [];
	attributeMap = [
		{
			key: 'generic.attack_speed',
			value: 4,
			modifiers: [
				{
					uuid: 'minecraft:base_attack_speed',
					amount: -2.4000000953674316,
					operation: 0
				}
			]
		}
	];
	activePotionsMap = {};
	constructor(index) {
		super(index);
		Object.assign(this.dataWatcher.data, {
			8: { key: 8, value: 0, type: 'byte' },
			9: { key: 9, value: 20, type: 'float' },
			10: { key: 10, value: [], type: 'particles' },
			11: { key: 11, value: false, type: 'boolean' },
			12: { key: 12, value: 0, type: 'int' },
			13: { key: 13, value: 0, type: 'int' },
			14: { key: 14, value: undefined, type: 'optional_block_pos' }
		});
	}
	updateEquipment(slot, item) {
		this.equipment[slot] = item ?? { itemCount: 0 };

		if (this.isLoaded) {
			this.world.client.write('entity_equipment', {
				entityId: this.minecraftId,
				equipments: [
					{
						slot: slot,
						item: this.equipment[slot]
					}
				]
			});
		}
	}
	updateAttributes(attributes) {
		this.attributeMap = attributes;

		if (this.isLoaded) {
			this.world.client.write('update_attributes', {
				entityId: this.minecraftId,
				properties: this.attributeMap
			});
		}
	}
	addPotionEffect(effect) {
		this.activePotionsMap[effect.effectId] = effect;

		if (this.isLoaded) {
			this.world.client.write('entity_effect', {
				entityId: this.minecraftId,
				effectId: effect.effectId,
				amplifier: effect.amplifier,
				duration: effect.duration,
				flags: effect.flags
			});
		}
	}
	removePotionEffect(id) {
		const didExist = this.activePotionsMap[id] != undefined;
		delete this.activePotionsMap[id];

		if (this.isLoaded && didExist) {
			this.world.client.write('remove_entity_effect', {
				entityId: this.minecraftId,
				effectId: id
			});
		}
	}
};
