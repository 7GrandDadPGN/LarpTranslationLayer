const fs = require('fs');
const readline = require('node:readline');

function selectGame(game) {
	console.log(`\x1b[32m[*] Loading ${game}...\x1b[0m`);
	require('./' + game + '/index.js');
}

module.exports = async function (args) {
	const games = fs.readdirSync('./src').filter((entry) => !(entry.includes('.') || entry == 'base'));
	if (args.game != undefined && games.includes(args.game)) {
		selectGame(args.game);
		return;
	}

	const rl = readline.createInterface({
		input: process.stdin,
		output: process.stdout
	});

	console.log(`\x1b[33m[*] Please select a game.\x1b[0m`);
	for (const index in games) {
		console.log(`\x1b[32m${Number.parseInt(index) + 1}. ${games[index]}\x1b[0m`);
	}

	let noOption = true;
	while (noOption) {
		const index = await new Promise((resolve) => {
			rl.question('Game Index: ', (response) => resolve(Number.parseInt(response)));
		});

		if (games[index - 1] != undefined) {
			selectGame(games[index - 1]);
			return;
		}

		console.log('\x1b[31m[!] Invalid game, please try again!\x1b[0m');
	}
};
