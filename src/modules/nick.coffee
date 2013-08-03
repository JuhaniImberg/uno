Base_Module = require './base_module'

class Nick extends Base_Module
	hooks: [{event: 'connect', callback: (self) -> con(self)}]
	
	con = (self) ->
		uno = self.uno
		config = self.config
		
		config.nick = if config.nick then config.nick else "uno"
		config.realname = if config.realname then config.realname else "Uno Not One"

		uno.send 'NICK', config.nick
		uno.send 'USER', config.nick, '0 *:'+config.nick, config.realname

	info:
		name: "nick",
		author: "Juhani Imberg",
		version: "1",
		description: "nick services"
		depends: []

module.exports = Nick