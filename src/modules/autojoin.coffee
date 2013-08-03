Base_Module = require './base_module'

class Autojoin extends Base_Module
	hooks: [{event: 'MODE', once: true, callback: (self) -> autojoin(self)}]

	autojoin = (self) ->
		uno = self.uno
		config = self.config
		if config.channels
			for i in config.channels
				uno.send 'JOIN', i

	info:
		name: "autojoin",
		author: "Juhani Imberg",
		version: "1",
		description: "automatically joins channels"
		depends: []

module.exports = Autojoin