const mcData = require('minecraft-data')('1.21.11');
const TablistHandler = require('../handlers/tablisthandler.js');
const Player = require('./entities/player/player.js');
const RequestQueue = require('./queue.js');
const Vec3 = require('vec3');
const VIEW_DISTANCE = 8;

module.exports = class World {
	local = new Player();
	chunkQueue = new RequestQueue();
	chunks = {};
	entities = {};
	nextEntityId = 2;
	expireTime = 1000;
	constructor(dimensionId, difficulty) {
		this.dimensionId = dimensionId;
		this.difficulty = difficulty;
		this.local.minecraftId = 1;
		this.local.isLoaded = true;
		this.local.world = this;
	}
	start(client, isFirst, handler) {
		this.client = client;
		this.tablist = new TablistHandler(client);
		this.local.uuid = this.client.uuid;
		handler.local = this.local;
		handler.tablist = this.tablist;

		this.client.write('login', {
			...mcData.loginPacket,
			entityId: 1,
			worldNames: ['minecraft:overworld'],
			maxPlayers: 255,
			viewDistance: VIEW_DISTANCE + 2,
			simulationDistance: VIEW_DISTANCE,
			worldState: {
				dimension: this.dimensionId,
				name: 'minecraft:overworld',
				hashedSeed: [0, 0],
				gamemode: 'survival',
				previousGamemode: 255,
				isDebug: false,
				isFlat: false,
				portalCooldown: 0,
				seaLevel: 0
			}
		});

		this.client.write('game_state_change', {
			reason: 13,
			gamemode: 0
		});
	}
	stop() {
		if (this.client != undefined && !this.client.ended) {
			this.tablist.clear();
			this.client.write('login', {
				...mcData.loginPacket,
				entityId: 1,
				worldNames: ['minecraft:overworld'],
				maxPlayers: 255,
				viewDistance: VIEW_DISTANCE + 2,
				simulationDistance: VIEW_DISTANCE,
				worldState: {
					dimension: 2,
					name: 'minecraft:overworld',
					hashedSeed: [0, 0],
					gamemode: 'survival',
					previousGamemode: 0,
					isDebug: false,
					isFlat: false,
					portalCooldown: 0,
					seaLevel: 0
				}
			});
		}
	}
	update(pos) {
		const x = pos.x >> 4,
			z = pos.z >> 4;
		const loaded = [],
			requests = [];

		this.client.write('update_view_position', {
			chunkX: x,
			chunkZ: z
		});

		for (let checkX = -VIEW_DISTANCE; checkX < VIEW_DISTANCE; checkX++) {
			for (let checkZ = -VIEW_DISTANCE; checkZ < VIEW_DISTANCE; checkZ++) {
				const cPos = [x + checkX, z + checkZ];
				const chunk = this.getChunk(cPos[0], cPos[1]);

				if (chunk) {
					if (!chunk.isLoaded) {
						chunk.load();
					}

					loaded.push(chunk);
				} else if (!this.chunkQueue.isInQueue(cPos[0], cPos[1])) {
					requests.push(cPos);
				}
			}
		}

		requests.sort((a, b) => {
			const aDist = Math.sqrt((a[0] - x) * (a[0] - x) + (a[1] - z) * (a[1] - z));
			const bDist = Math.sqrt((b[0] - x) * (b[0] - x) + (b[1] - z) * (b[1] - z));
			return bDist - aDist;
		});

		for (; requests.length > 0 && this.chunkQueue.getSize() < 16;) {
			const chunk = requests.pop();
			this.chunkQueue.queue(chunk[0], chunk[1], this.expireTime);

			if (this.requestCallback != undefined) {
				this.requestCallback(chunk);
			}
		}

		const removeList = Object.values(this.chunks).filter((chunk) => !loaded.includes(chunk));
		for (const chunk of removeList) {
			this.removeChunk(chunk.x, chunk.z);
		}
	}
	addEntity(index, entity) {
		this.entities[index] = entity;
		entity.minecraftId = this.nextEntityId++;
		entity.world = this;

		return entity;
	}
	getEntity(index, mc, isLocal) {
		if (isLocal && (mc ? this.local.minecraftId == index : this.local.index == index)) {
			return this.local;
		}

		return mc ? Object.values(this.entities).find((entity) => entity.minecraftId == index) : this.entities[index];
	}
	removeEntity(index) {
		const entity = this.entities[index];

		if (entity != undefined) {
			delete this.entities[index];

			if (entity.isLoaded) {
				this.client.write('entity_destroy', {
					entityIds: [entity.minecraftId]
				});
			}
		}
	}
	removeEntities(list) {
		let removeList = [];

		for (const index of list) {
			const entity = this.entities[index];
			if (entity != undefined) {
				delete this.entities[index];

				if (entity.isLoaded) {
					removeList.push(entity.minecraftId);
				}
			}
		}

		if (removeList.length > 0) {
			this.client.write('entity_destroy', {
				entityIds: removeList
			});
		}
	}
	tickEntities() {
		for (const entity of Object.values(this.entities)) {
			entity.tick();
		}
	}
	tickEntitiesInChunk(x, z) {
		for (const entity of Object.values(this.entities)) {
			if (entity.pos.x >> 4 == x && entity.pos.z >> 4 == z) {
				entity.tick();
			}
		}
	}
	addChunk(chunk) {
		this.chunkQueue.clear(chunk.x, chunk.z);
		this.chunks[chunk.x + ',' + chunk.z] = chunk;
		chunk.world = this;
		return chunk;
	}
	removeChunk(x, z) {
		const chunk = this.chunks[x + ',' + z];
		if (chunk != undefined) {
			chunk.unload();
			delete this.chunks[x + ',' + z];
		}
	}
	reloadWorld() {
		for (const chunk of Object.values(this.chunks)) {
			chunk.unload();
		}

		this.chunks = {};
		this.client.write('game_state_change', {
			reason: 13,
			gamemode: 0
		});
	}
	getChunk(x, z) {
		return this.chunks[x + ',' + z];
	}
	setBlock(vec, blockData) {
		const chunk = this.getChunk(vec.x >> 4, vec.z >> 4);
		if (chunk != undefined) {
			const relVec = new Vec3(vec.x - (vec.x >> 4) * 16, vec.y, vec.z - (vec.z >> 4) * 16);

			if (typeof blockData == 'number') {
				chunk.data.setBlockType(relVec, blockData);
			} else {
				chunk.data.setBlockType(relVec, blockData[0]);
				chunk.data.setBlockData(relVec, blockData[1]);
			}

			this.client.write('block_change', {
				location: vec,
				type: chunk.data.getBlockStateId(relVec)
			});
		}
	}
	getBlock(vec) {
		const chunk = this.getChunk(vec.x >> 4, vec.z >> 4);
		if (chunk != undefined) {
			return chunk.data.getBlockType(new Vec3(vec.x - (vec.x >> 4) * 16, vec.y, vec.z - (vec.z >> 4) * 16));
		}
	}
};
