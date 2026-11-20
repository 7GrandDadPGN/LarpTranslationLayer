module.exports = class ProxyChunk {
	isLoaded = false;
	constructor(x, z, data) {
		this.x = x;
		this.z = z;
		this.data = data;
	}
	load() {
		if (!this.isLoaded) {
			this.isLoaded = true;

			this.world.client.write('map_chunk', {
				x: this.x,
				z: this.z,
				heightmaps: [],
				chunkData: this.data.dump(),
				blockEntities: [],
				...this.data.dumpLight()
			});

			this.world.tickEntitiesInChunk(this.x, this.z);
		}
	}
	unload() {
		if (this.isLoaded) {
			this.isLoaded = false;
			this.world.tickEntitiesInChunk(this.x, this.z);

			this.world.client.write('unload_chunk', {
				chunkX: this.x,
				chunkZ: this.z
			});
		}
	}
};
