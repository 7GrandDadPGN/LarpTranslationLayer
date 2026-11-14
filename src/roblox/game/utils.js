const { parse } = require('node-html-parser');
const { COLOR_PALETTE, SPECIAL_CHARS, SPECIAL_REGEX } = require('./types/colors.js');

function colorDistance(color1, color2, rgb) {
	const rgb1 = rgb ? color1 : hexToRgb(color1);
	const rgb2 = hexToRgb(color2);
	return Math.sqrt(Math.pow(rgb1.r - rgb2.r, 2) + Math.pow(rgb1.g - rgb2.g, 2) + Math.pow(rgb1.b - rgb2.b, 2));
}

function findClosestColor(hex, rgb) {
	let closestColor = null;
	let closestDistance = Infinity;

	for (const color in COLOR_PALETTE) {
		const distance = colorDistance(hex, color, rgb);
		if (distance < closestDistance) {
			closestDistance = distance;
			closestColor = color;
		}
	}

	return COLOR_PALETTE[closestColor];
}

function hexToRgb(hex) {
	const bigint = parseInt(hex.slice(1), 16);
	return {
		r: (bigint >> 16) & 255,
		g: (bigint >> 8) & 255,
		b: bigint & 255
	};
}

function traverse(node, str, store, used) {
	const localStore = Object.assign({}, store);
	if (node.nodeType == 1 && node.rawTagName == 'font') {
		const color = node.getAttribute('color');
		if (color != undefined) {
			if (color.includes('#')) {
				localStore.color = `\u00a7${findClosestColor(color)}`;
			} else if (color.includes('rgb')) {
				const split = color
					.substring(4, color.length - 1)
					.split(',')
					.map((val) => parseFloat(val));

				localStore.color = `\u00a7${findClosestColor(
					{
						r: split[0],
						g: split[1],
						b: split[2]
					},
					true
				)}`;
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
			let changed = false;
			if (store.color != used.color || (store.bold != used.bold && used.bold) || (store.italic != used.italic && used.italic) || (store.underline != used.underline && used.underline)) {
				str += store.color || '\u00a7b';
				changed = true;
			}

			if (store.bold && (store.bold != used.bold || changed)) str += '\u00a7l';
			if (store.italic && (store.italic != used.italic || changed)) str += '\u00a7o';
			if (store.underline && (store.underline != used.underline || changed)) str += '\u00a7n';

			for (const key in used) {
				delete used[key];
			}

			Object.assign(used, store);
		}

		str += node._rawText;
	}

	for (const subnode of node.childNodes) {
		str = traverse(subnode, str, localStore, used);
	}

	return str;
}

module.exports = {
	translateText: function (str) {
		let finalStr = traverse(parse(str), '', {}, {});
		finalStr = finalStr.replaceAll('/c/', '\u00a7');
		finalStr = finalStr.replaceAll(SPECIAL_REGEX, (char) => {
			return SPECIAL_CHARS[char] || char;
		});

		return finalStr;
	},
	createItem: function (data, count) {
		let item = {
			blockId: data.id,
			itemCount: count,
			itemDamage: data.damage ?? 0,
			nbtData: {
				type: 'compound',
				name: '',
				value: {
					Unbreakable: { type: 'byte', value: 1 }
				}
			}
		};

		if (data.name) {
			item.nbtData.value.display = {
				type: 'compound',
				value: {
					Name: { type: 'string', value: '\u00a7r' + data.name }
				}
			};
		}

		if (data.enchants) {
			let enchants = [];

			for (const ench of data.enchants) {
				enchants.push({
					lvl: { type: 'short', value: ench[1] },
					id: { type: 'short', value: ench[0] }
				});
			}

			item.nbtData.value.ench = {
				type: 'list',
				value: {
					type: 'compound',
					value: enchants
				}
			};
		}

		return item;
	}
};
