Base_Module = require './base_module'

class Auth extends Base_Module
	hooks: [{event: 'COMMAND.auth', callback: (self, data) -> process(self, data)}]
	
	process = (self, data) ->
		uno = self.uno
		config = self.config
		
		uno.info data.arguments

	info:
		name: "auth",
		author: "Juhani Imberg",
		version: "1",
		description: "user authentication"
		depends: ["command"]

module.exports = Auth