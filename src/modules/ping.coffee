Base_Module = require './base_module'

class Ping extends Base_Module
	hooks: [{event: 'PING', callback: (self, data) -> ping(self, data)}]

	ping = (self, data) ->
		uno = self.uno
		config = self.config
		
		uno.send 'PONG', ':'+data.params[0]

	info:
		name: "ping",
		author: "Juhani Imberg",
		version: "1",
		description: "responds to PING with PONG"
		depends: []

module.exports = Ping