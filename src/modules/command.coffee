Base_Module = require './base_module'

class Command extends Base_Module
	hooks: [{event: 'PRIVMSG', callback: (self, data) -> parsa(self, data)}]
	
	parsa = (self, data) ->
		uno = self.uno
		config = self.config
		
		message = data.params[1].split ' '

		if message[0].indexOf(config.prefix) == 0
			args =
				command: message[0].substring 1
				arguments: message[1..]
				sender: data.prefix.split('!')[0].replace('~','').substring[1]
				reciever: data.params[0]
				is_channel: data.params[0].indexOf('#') == 0
				is_ctcp: data.params[1].split('\u0001').length == 3

			uno.emit 'COMMAND', args
			uno.emit 'COMMAND.'+args.command, args

	info:
		name: "command",
		author: "Juhani Imberg",
		version: "1",
		description: "adds command events"
		depends: []

module.exports = Command