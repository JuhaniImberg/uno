Base_Module = require './base_module'

class Auth extends Base_Module
	hooks: [{event: 'command.auth', callback: (self, data) -> auth_command(self, data)},
			{event: 'MODE', once: true, callback: (self) -> autoadmin(self)},
			{event: 'notice.STATUS', callback: (self, data) -> noticed(self, data)}]
	
	admins = []
	waiting = []

	load: ->
		waiting = @config.admins
		super()

	auth_command = (self, data) ->
		uno = self.uno
		config = self.config

		uno.info data.arguments[0]
		
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
		uno = self.uno
		config = self.config

		name = data.arguments[0]
		status = data.arguments[1]

		if status == '3'
			pos = waiting.indexOf name
			if pos == -1
				return
			pos2 = admins.indexOf name
			if pos2 != -1
				return
			waiting.splice pos, 1
			admins.push name
		else
			pos = admins.indexOf name
			if pos == -1
				return
			admins.splice pos, 1
			pos2 = waiting.indexOf name
			if pos2 == -1
				waiting.push name


	info:
		name: "auth",
		author: "Juhani Imberg",
		version: "1",
		description: "user authentication"
		depends: ["command"]

module.exports = Auth