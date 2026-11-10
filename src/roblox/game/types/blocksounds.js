const mcData = require('minecraft-data')('1.8.9');
const STEPSOUNDS = {
	wood: ['step.wood'],
	gravel: ['step.gravel'],
	grass: ['step.grass'],
	metal: ['step.stone', 1.5],
	cloth: ['step.cloth'],
	sand: ['step.sand'],
	snow: ['step.snow'],
	slime: ['mob.slime.small']
};

module.exports = {
	BLOCKSOUNDS: {
		[mcData.blocksByName.planks.id]: STEPSOUNDS.wood,
		[mcData.blocksByName.bed.id]: STEPSOUNDS.wood,
		[mcData.blocksByName.bookshelf.id]: STEPSOUNDS.wood,
		[mcData.blocksByName.chest.id]: STEPSOUNDS.wood,
		[mcData.blocksByName.crafting_table.id]: STEPSOUNDS.wood,
		[mcData.blocksByName.log.id]: STEPSOUNDS.wood,
		[mcData.blocksByName.log2.id]: STEPSOUNDS.wood,
		[mcData.blocksByName.wooden_slab.id]: STEPSOUNDS.wood,
		[mcData.blocksByName.dirt.id]: STEPSOUNDS.gravel,
		[mcData.blocksByName.gravel.id]: STEPSOUNDS.gravel,
		[mcData.blocksByName.farmland.id]: STEPSOUNDS.gravel,
		[mcData.blocksByName.clay.id]: STEPSOUNDS.gravel,
		[mcData.blocksByName.grass.id]: STEPSOUNDS.grass,
		[mcData.blocksByName.sponge.id]: STEPSOUNDS.grass,
		[mcData.blocksByName.tnt.id]: STEPSOUNDS.grass,
		[mcData.blocksByName.mycelium.id]: STEPSOUNDS.grass,
		[mcData.blocksByName.hay_block.id]: STEPSOUNDS.grass,
		[mcData.blocksByName.gold_block.id]: STEPSOUNDS.metal,
		[mcData.blocksByName.iron_block.id]: STEPSOUNDS.metal,
		[mcData.blocksByName.mob_spawner.id]: STEPSOUNDS.metal,
		[mcData.blocksByName.diamond_block.id]: STEPSOUNDS.metal,
		[mcData.blocksByName.emerald_block.id]: STEPSOUNDS.metal,
		[mcData.blocksByName.wool.id]: STEPSOUNDS.cloth,
		[mcData.blocksByName.cactus.id]: STEPSOUNDS.cloth,
		[mcData.blocksByName.carpet.id]: STEPSOUNDS.cloth,
		[mcData.blocksByName.sand.id]: STEPSOUNDS.sand,
		[mcData.blocksByName.soul_sand.id]: STEPSOUNDS.sand,
		[mcData.blocksByName.snow.id]: STEPSOUNDS.snow,
		[mcData.blocksByName.snow_layer.id]: STEPSOUNDS.snow,
		[mcData.blocksByName.slime.id]: STEPSOUNDS.slime
	}
};
