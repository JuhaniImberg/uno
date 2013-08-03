Base_Module = require './base_module'

class Notice extends Base_Module
	hooks: [{event: 'NOTICE', callback: (self, data) -> parsa(self, data)}]
	
	parsa = (self, data) ->
		uno = self.uno
		config = self.config

		message = data.params[1].split ' '

		args =
			command: message[0]
			arguments: message[1..]
			sender: data.prefix.split('!')[0].replace('~','').substring(1)
			reciever: data.params[0]
			is_channel: data.params[0].indexOf('#') == 0
			is_ctcp: data.params[1].split('\u0001').length == 3
			respond: if data.params[0].indexOf('#') == 0 then data.params[0] else data.prefix.split('!')[0].replace('~','').substring(1)

		uno.emit 'notice', args
		uno.emit 'notice.'+args.command, args
		uno.info 'notice.'+args.command+' '+args.arguments.join ' '

	info:
		name: "notice",
		author: "Juhani Imberg",
		version: "1",
		description: "adds notice events"
		depends: []

module.exports = Notice