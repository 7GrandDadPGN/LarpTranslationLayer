const { translateText } = require('../../utils.js');
const Handler = require('./../handler.js');
let client;

const self = class TabListHandler extends Handler {
	roblox(socket) {
		socket.on('scoreboard', (packet) => {
			// Add extra text just for no reason lol
			if (packet.lines.length < 15) {
				if (packet.lines.length > 0 && packet.lines[packet.lines.length - 1].replace(/\s/g, '').length > 0) {
					packet.lines.push(' ');
				}

				packet.lines.push('<font color="#ffff00">roblox.com</font>');
			}

			if (this.title == undefined) {
				client.write('scoreboard_objective', {
					name: 'scoreboard',
					action: 0,
					displayText: translateText(packet.title),
					type: 0,
					styling: { type: 'compound', name: '', value: [] }
				});

				client.write('scoreboard_display_objective', {
					position: 1,
					name: 'scoreboard'
				});
			} else if (this.title != packet.title) {
				client.write('scoreboard_objective', {
					name: 'scoreboard',
					action: 2,
					displayText: translateText(packet.title),
					type: 0,
					styling: { type: 'compound', name: '', value: [] }
				});
			}

			this.title = packet.title;

			const oldLen = this.score.length;
			if (oldLen > packet.lines.length) {
				for (let index = packet.lines.length; index < oldLen; index++) {
					if (packet.lines[index] == undefined) {
						client.write('reset_score', {
							entity_name: this.score[index],
							objective_name: 'scoreboard'
						});
					}

					delete this.score[index];
				}
			}

			const dupeList = [];
			for (let index = 0; index < packet.lines.length; index++) {
				let name = packet.lines[index];
				for (let i = 0; i < 10; i++) {
					if (dupeList.includes(name)) {
						name = name + ' ';
					} else {
						dupeList.push(name);
						break;
					}
				}

				if (this.score[index] && this.score[index] != name) {
					client.write('reset_score', {
						entity_name: this.score[index],
						objective_name: 'scoreboard'
					});
				}

				client.write('scoreboard_score', {
					scoreName: 'scoreboard',
					itemName: name,
					display_name: translateText(name),
					value: packet.lines.length - index
				});

				this.score[index] = name;
			}
		});
	}
	minecraft(mcClient) {
		client = mcClient;
	}
	cleanup(requeue) {
		client = requeue ? client : undefined;
		this.score = [];
		this.title = undefined;

		if (client != undefined) {
			client.write('scoreboard_objective', {
				name: 'scoreboard',
				action: 1
			});
		}
	}
};

module.exports = new self();
