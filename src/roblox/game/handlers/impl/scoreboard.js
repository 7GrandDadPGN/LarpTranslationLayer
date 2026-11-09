const { translateText } = require('../../utils.js');
const Handler = require('./../handler.js');
let client;

const self = class TabListHandler extends Handler {
	roblox(socket) {
		socket.on('scoreboard', packet => {
			// Add extra text just for no reason lol
			if (packet.lines.length < 15) {
				if (packet.lines.length > 0 && packet.lines[packet.lines.length - 1].replace(/\s/g, '').length > 0) {
					packet.lines.push('');
				}

				packet.lines.push('\u00a7eroblox.com');
			}

			const newTitle = packet.title.replaceAll(String.fromCharCode(65533), '\u00a7').slice(0, 16);
			if (this.title == undefined) {
				client.write('scoreboard_objective', {
					name: 'scoreboard',
					action: 0,
					displayText: packet.title.replaceAll(String.fromCharCode(65533), '\u00a7').slice(0, 16),
					type: 'INTEGER'
				});

				client.write('scoreboard_display_objective', {
					position: 1,
					name: 'scoreboard'
				});
			} else if (this.title != newTitle) {
				client.write('scoreboard_objective', {
					name: 'scoreboard',
					action: 2,
					displayText: packet.title.replaceAll(String.fromCharCode(65533), '\u00a7').slice(0, 16),
					type: 'INTEGER'
				});
			}

			this.title = newTitle;

			const oldLen = this.score.length;
			if (oldLen > packet.lines.length) {
				for (let index = packet.lines.length; index < oldLen; index++) {
					if (packet.lines[index] == undefined) {
						client.write('scoreboard_score', {
							scoreName: 'scoreboard',
							itemName: this.score[index],
							action: 1
						});
					}

					delete this.score[index];
				}
			}

			const dupeList = [];
			for (let index = 0; index < packet.lines.length; index++) {
				let name = translateText(packet.lines[index]).slice(0, 40);
				for (let i = 0; i < 10; i++) {
					if (dupeList.includes(name)) {
						name = (name + ' ').slice(0, 40);
					} else {
						dupeList.push(name);
						break;
					}
				}

				if (this.score[index] && this.score[index] != name) {
					client.write('scoreboard_score', {
						scoreName: 'scoreboard',
						itemName: this.score[index],
						action: 1
					});
				}

				client.write('scoreboard_score', {
					scoreName: 'scoreboard',
					itemName: name,
					action: 0,
					value: packet.lines.length - index
				});

				this.score[index] = name;
			}

			/*const doUpdate = this.score.length == packet.lines.length;
			if (!doUpdate) {
				this.clear();

				client.write('scoreboard_objective', {
					name: 'scoreboard',
					action: 0,
					displayText: packet.title.replaceAll(String.fromCharCode(65533), '\u00a7').slice(0, 16),
					type: 'INTEGER'
				});

				client.write('scoreboard_display_objective', {
					position: 1,
					name: 'scoreboard'
				});
			}

			let index = 0;
			for (const line of packet.lines) {
				const name = translateText(line).slice(0, 40);

				if (doUpdate) {
					if (this.score[index] == name) {
						index++;
						continue;
					}

					client.write('scoreboard_score', {
						scoreName: 'scoreboard',
						itemName: this.score[index],
						action: 1
					});

					this.score[index] = name;
				} else {
					this.score.push(name);
				}

				client.write('scoreboard_score', {
					scoreName: 'scoreboard',
					itemName: name,
					action: 0,
					value: packet.lines.length - index
				});

				index++;
			}*/
		});
	}
	minecraft(mcClient) {
		client = mcClient;
	}
	cleanup(requeue) {
		client = requeue ? client : undefined;
		this.score = [];
		this.title = undefined;
	}
};

module.exports = new self();