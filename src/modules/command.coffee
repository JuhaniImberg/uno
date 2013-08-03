Base_Module = require './base_module'

class Command extends Base_Module
	hooks: [{event: 'PRIVMSG', callback: (self, data) -> parsa(self, data)}]
	
	parsa = (self, data) ->
		uno = self.uno
		config = self.config
		
		message = data.params[1].split ' '

		if message[0].indexOf(config.prefix) == 0
			args =
				command_prefix: config.prefix
				command: message[0].substring 1
				arguments: message[1..]
				sender: data.prefix.split('!')[0].replace('~','').substring(1)
				reciever: data.params[0]
				is_channel: data.params[0].indexOf('#') == 0
				is_ctcp: data.params[1].split('\u0001').length == 3
				respond: if data.params[0].indexOf('#') == 0 then data.params[0] else data.prefix.split('!')[0].replace('~','').substring(1)

			uno.emit 'command', args
			uno.emit 'command.'+args.command, args
			uno.info 'command.'+args.command+' '+args.arguments.join ' '

	info:
		name: "command",
		author: "Juhani Imberg",
		version: "1",
		description: "adds command events"
		depends: []

module.exports = Command