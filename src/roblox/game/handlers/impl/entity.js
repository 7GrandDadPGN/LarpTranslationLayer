const Handler = require('../handler.js');
const packets = require('../../packets/init.js');
const EntityPlayerMP = require('../../../../base/translation/classes/entities/player/entityplayermp.js');
const EntityPlayer = require('../../../../base/translation/classes/entities/player/entityplayer.js');
const EntityLivingBase = require('../../../../base/translation/classes/entities/entitylivingbase.js');
let client, tablist, world, cSocket, MCHandler;

const self = class EntityHandler extends Handler {
	spawned = false
	roblox(socket) {
		cSocket = socket;
		// UNIVERSAL
		socket.on('entity_spawn', packet => {
			if (packet.isLocal) {
				MCHandler.local.pos = {x: packet.pos.x, y: packet.pos.y, z: packet.pos.z};
				MCHandler.local.index = packet.id;
				MCHandler.local.spawn();
				if (this.spawned) {
					client.write('respawn', {
						dimension: 0,
						difficulty: 2,
						gamemode: 2,
						levelType: 'FLAT'
					});
				}

				this.spawned = true;
				client.write('position', {
					x: packet.pos.x,
					y: packet.pos.y,
					z: packet.pos.z,
					yaw: packet.yaw,
					pitch: packet.pitch,
					flags: 0
				});

				MCHandler.world.update(MCHandler.local.pos);
			} else {
				const entity = MCHandler.world.addEntity(packet.id, new EntityPlayerMP(packet.id));
				entity.bot = packet.isBot ? {} : undefined;

				entity.moveEntity({
					x: packet.pos.x,
					y: packet.pos.y,
					z: packet.pos.z
				}, {
					yaw: packet.yaw,
					pitch: packet.pitch
				}, packet.onGround ?? false);
			}
		});

		socket.on('entity_remove', packet => {
			MCHandler.world.removeEntity(packet.id);
		});

		socket.on('entity_move', packet => {
			const entity = MCHandler.world.getEntity(packet.id);
			if (!entity) return;

			entity.moveEntity({
				x: packet.pos.x,
				y: packet.pos.y,
				z: packet.pos.z
			}, {
				yaw: packet.yaw,
				pitch: packet.pitch
			}, packet.onGround ?? false);
		});

		socket.on('entity_health', packet => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.dataWatcher.updateObject(6, packet.health);

				if (packet.id == MCHandler.local.index) {
					client.write('update_health', {
						health: packet.health,
						food: 19,
						foodSaturation: 0
					});
				}
			}
		});

		socket.on('entity_absorption', packet => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.dataWatcher.updateObject(17, packet.amount);
			}
		});

		socket.on('entity_status', packet => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.setEntityState(packet.status);
			}
		});

		socket.on('entity_state', packet => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.dataWatcher.updateObject(0, packet.state ? entity.dataWatcher.getObject(0) | (1 << packet.flag) : entity.dataWatcher.getObject(0) & ~(1 << packet.flag));
			}
		});

		socket.on('entity_animation', packet => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.playAnimation(packet.animation);
			}
		});

		socket.on('entity_equipment', packet => {
			const entity = MCHandler.world.getEntity(packet.id);
			if (entity) {
				entity.updateEquipment(packet.slot, packet.item);
			}
		});

		socket.on('teleport', packet => {
			client.write('position', {
				x: packet.x,
				y: packet.y,
				z: packet.z,
				yaw: 0,
				pitch: 0,
				flags: 24
			});
		});

		socket.on('respawn', packet => {

		});

		socket.on('experience', packet => {
			client.write('experience', {
				experienceBar: packet.experienceBar,
				level: packet.level,
				totalExperience: packet.totalExperience
			});
		});
	}
	minecraft(mcClient) {
		client = mcClient;

		client.on('flying', ({ onGround } = {}) => {
			if (MCHandler.world == undefined) return;
			if (!this.spawned) return;
			MCHandler.local.onGround = onGround;

			cSocket.send(packets.CLIENT.move({
				pos: MCHandler.local.pos,
				yaw: MCHandler.local.yaw,
				pitch: MCHandler.local.pitch,
				onGround: onGround
			}));
		});

		client.on('position', ({ x, y, z, onGround } = {}) => {
			if (MCHandler.world == undefined) return;
			if (!this.spawned) return;
			MCHandler.local.pos = {x: x, y: y, z: z};
			MCHandler.local.onGround = onGround;
			MCHandler.world.update(MCHandler.local.pos);

			cSocket.send(packets.CLIENT.move({
				pos: MCHandler.local.pos,
				yaw: MCHandler.local.yaw,
				pitch: MCHandler.local.pitch,
				onGround: onGround
			}));
		});

		client.on('look', ({ yaw, pitch, onGround } = {}) => {
			if (MCHandler.world == undefined) return;
			if (!this.spawned) return;
			MCHandler.local.yaw = yaw;
			MCHandler.local.pitch = pitch;
			MCHandler.local.onGround = onGround;

			cSocket.send(packets.CLIENT.move({
				pos: MCHandler.local.pos,
				yaw: MCHandler.local.yaw,
				pitch: MCHandler.local.pitch,
				onGround: onGround
			}));
		});

		client.on('position_look', ({ x, y, z, onGround, yaw, pitch } = {}) => {
			if (MCHandler.world == undefined) return;
			if (!this.spawned) return;
			MCHandler.local.yaw = yaw;
			MCHandler.local.pitch = pitch;
			MCHandler.local.pos = {x: x, y: y, z: z};
			MCHandler.local.onGround = onGround;
			MCHandler.world.update(MCHandler.local.pos);

			cSocket.send(packets.CLIENT.move({
				pos: MCHandler.local.pos,
				yaw: MCHandler.local.yaw,
				pitch: MCHandler.local.pitch,
				onGround: onGround
			}));
		});

		client.on('held_item_slot', packet => {
			if (MCHandler.world == undefined) return;
			cSocket.send(packets.CLIENT['switch_slot'](packet));
		});

		client.on('arm_animation', packet => {
			if (MCHandler.world == undefined) return;
			cSocket.send(packets.CLIENT['arm_animation']());
		});

		client.on('entity_action', packet => {
			if (MCHandler.world == undefined) return;
			cSocket.send(packets.CLIENT['entity_action'](packet));
		});

		client.on('use_entity', packet => {
			if (MCHandler.world == undefined) return;
			const entity = packet.target != undefined && MCHandler.world.getEntity(packet.target, true, true);

			if (entity != undefined && packet.mouse == 1) {
				cSocket.send(packets.CLIENT.attack({
					id: entity.index
				}));
			}
		});
	}
	cleanup(requeue) {
		client = requeue ? client : undefined;
		this.spawned = false;
	}
	obtainHandlers(handlers, mchandler) {
		tablist = handlers.tablist;
		world = handlers.world;
		MCHandler = mchandler;
	}
};

module.exports = new self();
