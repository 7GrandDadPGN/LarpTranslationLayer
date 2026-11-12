const { parse } = require('node-html-parser');
const { COLOR_PALETTE, COLOR_REGEX } = require('./types/colors.js');

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

function traverse(node, str, colorStore, parent) {
	if (node.nodeType == 1 && node.rawTagName == 'font') {
		const color = node.getAttribute('color');
		if (color != undefined) {
			if (color.includes('#')) {
				str += `\u00a7${findClosestColor(color)}`;
			} else if (color.includes('rgb')) {
				const split = color
					.substring(4, color.length - 1)
					.split(',')
					.map((val) => parseFloat(val));

				str += `\u00a7${findClosestColor(
					{
						r: split[0],
						g: split[1],
						b: split[2]
					},
					true
				)}`;
			}

			colorStore.color = true;
		}
	} else if (node.nodeType == 1 && node.rawTagName == 'b') {
		colorStore.bold = true;
		str += `\u00a7l`;
	} else if (node.nodeType == 1 && node.rawTagName == 'i') {
		colorStore.italic = true;
		str += `\u00a7o`;
	} else if (node.nodeType == 1 && node.rawTagName == 'u') {
		colorStore.underline = true;
		str += `\u00a7n`;
	} else if (node.nodeType == '3') {
		if (parent == undefined) {
			if (colorStore.bold || colorStore.italic || colorStore.underline || colorStore.color) {
				str += '\u00a7b';
			}

			delete colorStore.bold;
			delete colorStore.italic;
			delete colorStore.underline;
			delete colorStore.color;
		}

		str += node._rawText;
	}

	for (const subnode of node.childNodes) {
		str = traverse(subnode, str, node);
	}

	return str;
}

module.exports = {
	translateText: function (str) {
		let finalStr = traverse(parse(str), '', {});
		finalStr = finalStr.replaceAll('/c/', '\u00a7');
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
