const { parse } = require('node-html-parser');
const { COLOR_PALETTE, SPECIAL_CHARS, SPECIAL_REGEX } = require('./types/colors.js');
const nbt = require('prismarine-nbt');

function traverse(node, str, store, used) {
	const localStore = Object.assign({}, store);
	if (node.nodeType == 1 && node.rawTagName == 'font') {
		const color = node.getAttribute('color');
		if (color != undefined) {
			if (color.includes('#')) {
				localStore.color = color;
			} else if (color.includes('rgb')) {
				const split = color
					.substring(4, color.length - 1)
					.split(',')
					.map((val) => parseFloat(val));

				localStore.color = `#${split.map((val) => val.toString(16).padStart(2, '0')).join('')}`;
			}
		}
	} else if (node.nodeType == 1 && node.rawTagName == 'b') {
		localStore.bold = true;
	} else if (node.nodeType == 1 && node.rawTagName == 'i') {
		localStore.italic = true;
	} else if (node.nodeType == 1 && node.rawTagName == 'u') {
		localStore.underline = true;
	} else if (node.nodeType == '3') {
		if (store.color != used.color || store.bold != used.bold || store.italic != used.italic || store.underline != used.underline) {
			for (const key in used) {
				delete used[key];
			}

			Object.assign(used, store);
		}

		const obj = {
			text: { type: 'string', value: node._rawText }
		};

		if (localStore.color) obj.color = { type: 'string', value: localStore.color };
		if (localStore.bold) obj.bold = { type: 'boolean', value: true };
		if (localStore.italic) obj.italic = { type: 'boolean', value: true };
		if (localStore.underline) obj.underlined = { type: 'boolean', value: true };

		str.push(obj);
	}

	for (const subnode of node.childNodes) {
		str = traverse(subnode, str, localStore, used);
	}

	return str;
}

function translateText(str) {
	str = str.replaceAll(SPECIAL_REGEX, (char) => {
		return SPECIAL_CHARS[char] || char;
	});

	return {
		type: 'compound',
		name: '',
		value: {
			text: { type: 'string', value: '' },
			extra: {
				type: 'list',
				value: {
					type: 'compound',
					value: traverse(parse(str), [], {}, {})
				}
			}
		}
	};
}

function createItem(data, count, components) {
	if (data.id <= 0) {
		return { itemCount: 0 };
	}

	let item = {
		itemCount: count,
		itemId: data.id,
		addedComponentCount: components != undefined ? components.length : 0,
		removedComponentCount: 0,
		components: components ?? [],
		removeComponents: []
	};

	if (components != undefined) {
		for (const obj of components) {
			if (obj.type == 'custom_name') {
				obj.data = translateText(obj.data);
			}
		}
	}

	return item;
}

module.exports = {
	translateText: translateText,
	createItem: createItem,
	readItem: function (data, offset) {
		const id = data.readUInt32LE(offset);
		const nbtSize = data.readUInt16LE(offset + 5);
		const item = id != 0 ? createItem({ id: id >> 16, damage: id & 65535 }, data.readInt8(offset + 4), nbtSize > 0 ? JSON.parse(data.toString('utf8', offset + 7, offset + 7 + nbtSize)) : undefined) : { itemCount: 0 };

		return [item, offset + 7 + nbtSize];
	}
};
