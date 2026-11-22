const Handler = require('../handler.js');
const packets = require('../../packets/init.js');
const { ENTITIES } = require('../../types/entities.js');
let client, tablist, world, cSocket, MCHandler;

function convertToByte(num) {
	num &= 0xff;
	num = num > 127 ? num - 256 : num;
	return num;
}

const self = class EntityHandler extends Handler {
	spawned = false;
	health = { health: 20, food: 19, foodSaturation: 0 };
	roblox(socket) {
		cSocket = socket;
		// UNIVERSAL
		socket.on('entity_spawn', (packet) => {
			if (packet.isLocal) {
				if (this.spawned) {
					client.write('respawn', {
						worldState: {
							dimension: MCHandler.world.dimensionId,
							name: 'minecraft:overworld',
							hashedSeed: [0, 0],
							gamemode: 'survival',
							previousGamemode: 0,
							isDebug: false,
							isFlat: false,
							portalCooldown: 0,
							seaLevel: 0
						},
						copyMetadata: 0
					});

					MCHandler.local.dataWatcher.updateObject(9, 20, true);
				}

				MCHandler.local.pos = { x: packet.pos.x, y: packet.pos.y, z: packet.pos.z };
				MCHandler.local.index = packet.id;
				MCHandler.local.spawn();

				this.spawned = true;
				this.spawnPosition = { x: packet.pos.x, y: packet.pos.y, z: packet.pos.z };
				client.write('position', {
					teleportId: 1,
					x: packet.pos.x,
					y: packet.pos.y,
					z: packet.pos.z,
					yaw: packet.yaw,
					pitch: packet.pitch,
					flags: 0
				});

				MCHandler.world.update(MCHandler.local.pos);
			} else {
				const entity = MCHandler.world.addEntity(packet.id, new ENTITIES[packet.type](packet.id));
				entity.bot = packet.isBot ? {} : undefined;

				entity.moveEntity(
					{
						x: packet.pos.x,
						y: packet.pos.y,
						z: packet.pos.z
					},
					{
						yaw: packet.yaw,
						pitch: packet.pitch
					},
					packet.onGround ?? false
				);
			}
		});

		socket.on('entity_remove', (packet) => {
			MCHandler.world.removeEntity(packet.id);
		});

		socket.on('entity_move', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id);
			if (!entity) return;
			const dX = packet.pos.x - entity.pos.x;
			const dY = packet.pos.y - entity.pos.y;
			const dZ = packet.pos.z - entity.pos.z;

			entity.moveEntity(
				{
					x: packet.pos.x,
					y: packet.pos.y,
					z: packet.pos.z
				},
				{
					yaw: packet.yaw,
					pitch: packet.pitch
				},
				packet.onGround ?? false
			);

			if (!(packet.onGround && (entity.dataWatcher.getObject(0) & (1 << 1)) != 0)) {
				entity.stepDistance = (entity.stepDistance ?? 0) + Math.sqrt(dX * dX + dY * dY + dZ * dZ) * 0.6;

				if (entity.stepDistance > 1 && entity.isLoaded) {
					const stepBlock = MCHandler.world.getBlock({
						x: Math.floor(packet.pos.x),
						y: Math.floor(packet.pos.y - 0.2),
						z: Math.floor(packet.pos.z)
					});

					if (stepBlock != 0) {
						entity.stepDistance = 0;

						client.write('sound_effect', {
							sound: {
								soundId: 1543
							},
							soundCategory: 'player',
							x: packet.pos.x * 8,
							y: packet.pos.y * 8,
							z: packet.pos.z * 8,
							volume: 0.15,
							pitch: 1,
							seed: [Math.random() * 1000000, Math.random() * 1000000]
						});
					}
				}
			}
		});

		socket.on('entity_health', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.dataWatcher.updateObject(9, packet.health);

				if (packet.id == MCHandler.local.index) {
					this.health.health = packet.health;
					client.write('update_health', {
						health: this.health.health,
						food: this.health.food,
						foodSaturation: this.health.foodSaturation
					});

					if (packet.health <= 0) {
						this.spawnPosition = {};
					}
				}
			}
		});

		socket.on('update_hunger', (packet) => {
			this.health.food = packet.hunger;
			this.health.foodSaturation = packet.saturation;

			if (this.health.health <= 0) return;

			client.write('update_health', {
				health: this.health.health,
				food: this.health.food,
				foodSaturation: this.health.foodSaturation
			});
		});

		socket.on('entity_absorption', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.dataWatcher.updateObject(17, packet.amount);
			}
		});

		socket.on('entity_hurt', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity && entity.isLoaded) {
				client.write('damage_event', {
					entityId: entity.minecraftId,
					sourceTypeId: packet.damageType,
					sourceCauseId: 0,
					sourceDirectId: 0
				});

				if (entity == MCHandler.world.local) {
					client.write('hurt_animation', {
						entityId: entity.minecraftId,
						yaw: packet.yaw
					});
				}
			}
		});

		socket.on('entity_velocity', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity && entity.isLoaded) {
				client.write('entity_velocity', {
					entityId: entity.minecraftId,
					velocity: {
						x: packet.x,
						y: packet.y,
						z: packet.z
					}
				});
			}
		});

		socket.on('entity_state', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);

			if (entity) {
				if (packet.isLiving) {
					entity.dataWatcher.updateObject(8, convertToByte(packet.state ? entity.dataWatcher.getObject(8) | packet.flag : entity.dataWatcher.getObject(8) & ~packet.flag));
				} else {
					entity.dataWatcher.updateObject(0, convertToByte(packet.state ? entity.dataWatcher.getObject(0) | (1 << packet.flag) : entity.dataWatcher.getObject(0) & ~(1 << packet.flag)));
				}
			}
		});

		socket.on('entity_event', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.handleEntityEvent(packet.event);
			}
		});

		socket.on('entity_animation', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.playAnimation(packet.animation);
			}
		});

		socket.on('entity_effect', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.addPotionEffect(packet);
			}
		});

		socket.on('remove_entity_effect', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.removePotionEffect(packet.effectId);
			}
		});

		socket.on('entity_attributes', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				entity.updateAttributes(JSON.parse(packet.attributes));
			}
		});

		socket.on('entity_metadata', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id, false, true);
			if (entity) {
				for (const obj of JSON.parse(packet.metadata)) {
					console.log(obj.key, obj.value);
					if (obj.item) {
						entity.dataWatcher.updateObject(obj.key, obj.value.id != 0 ? createItem({ id: obj.value.id >> 16, damage: obj.value.id & 65535 }, obj.value.count, obj.value.nbt) : { itemCount: 0 });
					} else {
						entity.dataWatcher.updateObject(obj.key, obj.value);
					}
				}
			}
		});

		socket.on('entity_equipment', (packet) => {
			const entity = MCHandler.world.getEntity(packet.id);
			if (entity) {
				entity.updateEquipment(packet.slot, packet.item);
			}
		});

		socket.on('add_velocity', (packet) => {
			client.write('explosion', {
				center: {
					x: Number.MAX_VALUE,
					y: Number.MAX_VALUE,
					z: Number.MAX_VALUE
				},
				radius: 0,
				blockCount: 0,
				playerKnockback: {
					x: packet.x,
					y: packet.y,
					z: packet.z
				},
				explosionParticle: {
					type: 'gust_emitter_small'
				},
				sound: {
					soundId: 1705
				},
				blockParticles: []
			});
		});

		socket.on('teleport', (packet) => {
			client.write('position', {
				x: packet.x,
				y: packet.y,
				z: packet.z,
				yaw: 0,
				pitch: 0,
				flags: {
					yaw: true,
					pitch: true
				}
			});
		});

		socket.on('held_item_slot', (packet) => {
			client.write('held_item_slot', packet);
		});

		socket.on('respawn', (packet) => {});

		socket.on('experience', (packet) => {
			client.write('experience', {
				experienceBar: packet.experienceBar,
				level: packet.level,
				totalExperience: packet.totalExperience
			});
		});
	}
	minecraft(mcClient) {
		client = mcClient;

		client.on('flying', ({ flags } = {}) => {
			if (MCHandler.world == undefined) return;
			if (this.spawnPosition != undefined) return;
			MCHandler.local.onGround = flags.onGround;

			cSocket.send(
				packets.CLIENT.move({
					pos: MCHandler.local.pos,
					yaw: MCHandler.local.yaw,
					pitch: MCHandler.local.pitch,
					onGround: flags.onGround
				})
			);
		});

		client.on('position', ({ x, y, z, flags } = {}) => {
			if (MCHandler.world == undefined) return;
			if (this.spawnPosition != undefined) return;
			MCHandler.local.pos = { x: x, y: y, z: z };
			MCHandler.local.onGround = flags.onGround;

			cSocket.send(
				packets.CLIENT.move({
					pos: MCHandler.local.pos,
					yaw: MCHandler.local.yaw,
					pitch: MCHandler.local.pitch,
					onGround: flags.onGround
				})
			);
		});

		client.on('look', ({ yaw, pitch, flags } = {}) => {
			if (MCHandler.world == undefined) return;
			if (this.spawnPosition != undefined) return;
			MCHandler.local.yaw = yaw;
			MCHandler.local.pitch = pitch;
			MCHandler.local.onGround = flags.onGround;

			cSocket.send(
				packets.CLIENT.move({
					pos: MCHandler.local.pos,
					yaw: MCHandler.local.yaw,
					pitch: MCHandler.local.pitch,
					onGround: flags.onGround
				})
			);
		});

		client.on('position_look', ({ x, y, z, flags, yaw, pitch } = {}) => {
			if (MCHandler.world == undefined) return;
			if (this.spawnPosition != undefined) {
				if (this.spawnPosition.x == x && this.spawnPosition.y == y && this.spawnPosition.z == z) {
					this.spawnPosition = undefined;
				} else {
					return;
				}
			}

			MCHandler.local.yaw = yaw;
			MCHandler.local.pitch = pitch;
			MCHandler.local.pos = { x: x, y: y, z: z };
			MCHandler.local.onGround = flags.onGround;

			cSocket.send(
				packets.CLIENT.move({
					pos: MCHandler.local.pos,
					yaw: MCHandler.local.yaw,
					pitch: MCHandler.local.pitch,
					onGround: flags.onGround
				})
			);
		});

		client.on('client_command', (packet) => {
			if (MCHandler.world == undefined) return;
			cSocket.send(packets.CLIENT['client_command'](packet));
		});

		client.on('tick_end', (packet) => {
			if (MCHandler.world == undefined) return;
			MCHandler.world.update(MCHandler.local.pos);
			cSocket.send(packets.CLIENT['tick_end']());
		});

		client.on('player_input', (packet) => {
			if (MCHandler.world == undefined) return;
			if (packet.inputs.shift != MCHandler.local.sneaking) {
				cSocket.send(
					packets.CLIENT['entity_action']({
						actionId: packet.inputs.shift ? 'start_sneaking' : 'stop_sneaking'
					})
				);

				MCHandler.local.sneaking = packet.inputs.shift;
			}
		});

		client.on('held_item_slot', (packet) => {
			if (MCHandler.world == undefined) return;
			cSocket.send(packets.CLIENT['switch_slot'](packet));
		});

		client.on('arm_animation', (packet) => {
			if (MCHandler.world == undefined) return;
			cSocket.send(packets.CLIENT['arm_animation']());
		});

		client.on('use_item', (packet) => {
			if (MCHandler.world == undefined) return;
			cSocket.send(packets.CLIENT['use_item'](packet));
		});

		client.on('entity_action', (packet) => {
			if (MCHandler.world == undefined) return;
			cSocket.send(packets.CLIENT['entity_action'](packet));
		});

		client.on('use_entity', (packet) => {
			if (MCHandler.world == undefined) return;
			const entity = packet.target != undefined && MCHandler.world.getEntity(packet.target, true, true);

			if (entity != undefined && packet.mouse == 1) {
				cSocket.send(
					packets.CLIENT.attack({
						id: entity.index
					})
				);
			}
		});
	}
	cleanup(requeue) {
		client = requeue ? client : undefined;
		this.spawnPosition = {};
		this.spawned = false;
		this.health = { health: 20, food: 19, foodSaturation: 0 };
	}
	obtainHandlers(handlers, mchandler) {
		tablist = handlers.tablist;
		world = handlers.world;
		MCHandler = mchandler;
	}
};

module.exports = new self();
