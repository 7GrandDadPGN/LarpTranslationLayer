const fs = require('fs');
const StreamZip = require('node-stream-zip');
const { Command } = require('@cliffy/command');

const HASH_PATH = './hash.txt';
const ZIP_PATH = './temp.zip';

async function checkForUpdates() {
	console.log(`\x1b[32m[*] Checking for updates...\x1b[0m`);

	try {
		const hash = fs.existsSync(HASH_PATH) ? fs.readFileSync(HASH_PATH, {encoding: 'utf8'}) : '';
		const response = await fetch('https://api.github.com/repos/7GrandDadPGN/LarpTranslationLayer/branches/main', {
			method: 'GET',
			headers: {
				['Content-Type']: 'application/json'
			}
		}).then((data) => data.json());

		if (response.commit.sha != hash) {
			console.log(`\x1b[32m[*] Downloading update...\x1b[0m`);

			const zipData = await fetch('https://github.com/7GrandDadPGN/LarpTranslationLayer/archive/refs/heads/main.zip', {
				method: 'GET',
				headers: {
					['Content-Type']: 'application/octet-stream'
				}
			}).then((data) => data.bytes());

			fs.writeFileSync(ZIP_PATH, zipData);
			const zipFile = new StreamZip.async({
				file: ZIP_PATH
			});

			fs.rmSync('./src', {recursive: true});

			const zipEntries = await zipFile.entries();
			for (const entry of Object.values(zipEntries)) {
				if (entry.name.startsWith('LarpTranslationLayer-main/src')) {
					await zipFile.extract(entry.name, entry.name.replace('LarpTranslationLayer-main', '.'));
				}
			}

			zipFile.close();
			fs.rmSync(ZIP_PATH);
			fs.writeFileSync(HASH_PATH, response.commit.sha);
			console.log(`\x1b[32m[*] Updated to latest version!\x1b[0m`);
		} else {
			console.log(`\x1b[32m[*] Up to date!\x1b[0m`);
		}
	} catch (exception) {
		console.log(`Failed to check for updates: ${exception}`);
	}
}

async function main(args) {
	console.log(`\x1b[33mLarp Translation Layer Started!\nDeveloped & maintained by 7GrandDad (https://youtube.com/c/7GrandDadVape)\x1b[0m`);

	if (!args.ignoreUpdates) {
		await checkForUpdates();
	} else {
		console.log(`\x1b[32m[*] Skipped update check.\x1b[0m`);
	}

	(require('./src/main.js'))(args);
};

(async function() {
	await new Command()
		.name('Main')
		.description('Basic bundler dedicated for vape')
		.globalOption('--ignore-updates')
		.globalOption('--game [mode:string]')
		.action((args) => main(args))
		.parse();
})();