Base_Module = require './base_module'

class Help extends Base_Module
	hooks: [{event: 'command.help', callback: (self, data) -> process(self, data)}]
	
	process = (self, data) ->
		uno = self.uno
		config = self.config
		
		if data.arguments.length == 0
			uno.respond data, 'uno version: '+uno.version
			uno.respond data, 'modules: '+uno.get_loaded().join(", ")
			uno.respond data, 'additional info: '+data.command_prefix+'help [module name]'
		else
			module_info = uno.get_module data.arguments[0]
			if module_info
				info = module_info.module.info
				uno.respond data, 'name: '+info.name
				uno.respond data, 'description: '+info.description
				uno.respond data, 'author: '+info.author
				uno.respond data, 'version: '+info.version
			else
				uno.respond data, 'no such module'


	info:
		name: "help",
		author: "Juhani Imberg",
		version: "1",
		description: "gives help"
		depends: ["command"]

module.exports = Help