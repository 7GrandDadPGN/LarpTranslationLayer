const DataWatcher = require('../datawatcher.js');

function convertToByte(num) {
	num &= 0xff;
	num = num > 127 ? num - 256 : num;
	return num;
}

module.exports = class Entity {
	minecraftId = 2;
	uuid = crypto.randomUUID();
	pos = { x: 0, y: 0, z: 0 };
	motion = { x: 0, y: 0, z: 0 };
	yaw = 0;
	pitch = 0;
	onGround = false;
	isLoaded = false;
	dataWatcher = new DataWatcher(this);
	constructor(index) {
		this.index = index;
		Object.assign(this.dataWatcher.data, {
			0: { key: 0, value: 0, type: 'byte' },
			1: { key: 1, value: 300, type: 'int' },
			2: { key: 2, value: undefined, type: 'optional_component' },
			3: { key: 3, value: false, type: 'boolean' },
			4: { key: 4, value: false, type: 'boolean' },
			5: { key: 5, value: false, type: 'boolean' },
			6: { key: 6, value: 0, type: 'pose' },
			7: { key: 7, value: 0, type: 'int' }
		});
	}
	getAddEntityPacket() {
		return {
			entityId: this.minecraftId,
			objectUUID: this.uuid,
			type: this.typeId,
			x: this.pos.x,
			y: this.pos.y,
			z: this.pos.z,
			yaw: convertToByte(this.yaw),
			pitch: convertToByte(this.pitch),
			headPitch: convertToByte(this.pitch),
			objectData: 0,
			velocity: { x: 0, y: 0, z: 0 }
		};
	}
	spawn() {
		if (this != this.world.local) {
			this.world.client.write('spawn_entity', this.getAddEntityPacket());
		} else {
			this.world.client.write('game_state_change', {
				reason: 13,
				gamemode: 0
			});

			this.world.chunks = {};
			this.world.chunkQueue.queued = {};
		}

		this.world.client.write('entity_metadata', {
			entityId: this.minecraftId,
			metadata: Object.values(this.dataWatcher.data)
		});

		if (this.attributeMap != undefined) {
			this.world.client.write('entity_update_attributes', {
				entityId: this.minecraftId,
				properties: Object.values(this.attributeMap)
			});
		}

		if (this.equipment != undefined) {
			for (let i = 0; i < 6; i++) {
				this.world.client.write('entity_equipment', {
					entityId: this.minecraftId,
					equipments: [
						{
							slot: i,
							item: this.equipment[i] ?? { itemCount: 0 }
						}
					]
				});
			}
		}

		if (this.activePotionsMap != undefined) {
			for (const effect of Object.values(this.activePotionsMap)) {
				this.world.client.write('entity_effect', {
					entityId: this.minecraftId,
					effectId: effect.effectId,
					amplifier: effect.amplifier,
					duration: Math.max((effect.duration - Date.now()) / 50, 0),
					hideParticles: effect.hideParticles
				});
			}
		}
	}
	canSpawn() {
		const chunk = this.world.getChunk(this.pos.x >> 4, this.pos.z >> 4);
		return chunk && chunk.isLoaded ? true : false;
	}
	tick() {
		const state = this.canSpawn();
		if (state != this.isLoaded) {
			if (state) {
				this.spawn();
			} else {
				this.world.client.write('entity_destroy', {
					entityIds: [this.minecraftId]
				});
			}

			this.isLoaded = state;
		}
	}
	moveEntity(pos, angles, onGround) {
		const lastPos = { x: this.pos.x, y: this.pos.y, z: this.pos.z };

		if (pos != undefined) {
			if (pos.add) {
				this.pos.x += pos.x;
				this.pos.y += pos.y;
				this.pos.z += pos.z;
			} else {
				this.pos.x = pos.x;
				this.pos.y = pos.y;
				this.pos.z = pos.z;
			}

			this.tick();
		}

		if (angles != undefined) {
			this.yaw = angles.yaw;
			this.pitch = angles.pitch;
		}

		if (this.isLoaded) {
			const diffX = Math.round(this.pos.x * 4096) - Math.round(lastPos.x * 4096);
			const diffY = Math.round(this.pos.y * 4096) - Math.round(lastPos.y * 4096);
			const diffZ = Math.round(this.pos.z * 4096) - Math.round(lastPos.z * 4096);
			const encYaw = convertToByte((this.yaw * 256) / 360);
			const encPitch = convertToByte((this.pitch * 256) / 360);
			const newGround = onGround ?? false;

			if (!(diffX < -32768 || diffX > 32767 || diffY < -32768 || diffY > 32767 || diffZ < -32768 || diffZ > 32767 || newGround != this.onGround)) {
				this.world.client.write(pos != undefined && angles != undefined ? 'entity_move_look' : pos != undefined ? 'rel_entity_move' : 'entity_look', {
					entityId: this.minecraftId,
					dX: diffX,
					dY: diffY,
					dZ: diffZ,
					yaw: encYaw,
					pitch: encPitch,
					onGround: onGround ?? false
				});
			} else {
				this.world.client.write('sync_entity_position', {
					entityId: this.minecraftId,
					x: this.pos.x,
					y: this.pos.y,
					z: this.pos.z,
					dx: 0,
					dy: 0,
					dz: 0,
					yaw: encYaw,
					pitch: encPitch,
					flags: 0,
					onGround: onGround ?? false
				});
			}

			if (angles != undefined && angles.yaw != undefined) {
				this.world.client.write('entity_head_rotation', {
					entityId: this.minecraftId,
					headYaw: encYaw
				});
			}

			this.onGround = newGround;
		}
	}
	playAnimation(type) {
		if (this.isLoaded) {
			this.world.client.write('animation', {
				entityId: this.minecraftId,
				animation: type
			});
		}
	}
	handleEntityEvent(event) {
		if (this.isLoaded) {
			this.world.client.write('entity_status', {
				entityId: this.minecraftId,
				entityStatus: event
			});
		}
	}
	setVelocity(velocity) {
		Object.assign(this.motion, velocity);
		if (this.isLoaded) {
			this.world.client.write('entity_velocity', {
				entityId: this.minecraftId,
				velocityX: Math.max(Math.min(this.motion.x * 8000, 32767), -32768),
				velocityY: Math.max(Math.min(this.motion.y * 8000, 32767), -32768),
				velocityZ: Math.max(Math.min(this.motion.z * 8000, 32767), -32768)
			});
		}
	}
};
