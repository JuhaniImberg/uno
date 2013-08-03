Base_Module = require './base_module'

class Auth extends Base_Module
	hooks: [{event: 'command.auth', callback: (self, data) -> process(self, data)},
			{event: 'MODE', once: true, callback: (self) -> autoadmin(self)},
			{event: 'notice.status', callback: (self, data) -> noticed(self, data)}]
	
	admins = []
	waiting = []

	load: ->
		waiting = @config.admins
		super

	process = (self, data) ->
		uno = self.uno
		config = self.config

		data.arguments[0]
		
		if data.arguments.length == 0
			data.arguments.push 'list'
		
		switch data.arguments[0]
			when 'list'
				uno.respond data, 'admins: '+admins.join(", ")

	autoadmin = (self) ->
		uno = self.uno
		config = self.config

		for i in waiting
			uno.send 'PRIVMSG', 'NickServ', 'Status', i
		for i in admins
			uno.send 'PRIVMSG', 'NickServ', 'Status', i	

	noticed = (self, data) ->
		

	info:
		name: "auth",
		author: "Juhani Imberg",
		version: "1",
		description: "user authentication"
		depends: ["command"]

module.exports = Auth