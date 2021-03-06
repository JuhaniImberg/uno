{EventEmitter} = require 'events'
net = require 'net'
path = require 'path'
fs = require 'fs'

class UNO extends EventEmitter
	constructor: (@config) ->
		@version = '2.0.0-git'
		@emit 'init'
		@buffer = ""
		@modules = []
		@firstload = true

		@info 'you are rocking uno version '+@version
		@info 'connecting to '+@config.host+':'+@config.port

		@connect()

		@on 'connect', () ->
			@info 'connected'

	connect: () ->
		@socket = new net.Socket
		@socket.setEncoding @config.encoding
		@socket.setNoDelay()
		@socket.connect(@config.port, @config.host)

		@socket.on 'connect', () =>
			@emit 'connect'
		@socket.on 'data', (data) =>
			@buffer += data
			while @buffer.length
				offset = @buffer.indexOf '\r\n'
				if offset == -1
					return

				message = @buffer.substr 0, offset
				@buffer = @buffer.substr offset + 2
				@log '>', message
				message = @parse message
				if message
					@emit message.command, message


	send: () ->
		message = []
		for i in arguments
			if i
				message.push i
		message = message.join(' ')
		@log '<', message
		@socket.write message+'\r\n', @config.encoding

	respond: (data, message) ->
		@send 'PRIVMSG', data.respond, ':'+message

	parse: (data) ->
		m = data.match /(?:(:[^\s]+) )?([^\s]+) (.+)/
		params = m[3].match /(.*?) ?:(.*)/
		if params
			params[1] = if params[1] then params[1].split ' ' else []
			params[2] = if params[2] then [params[2]] else []
			params = params[1].concat params[2]
		else
			params = m[3].split ' '

		data =
			prefix: m[1]
			command: m[2]
			params: params

	log: (prefix, data) ->
		d = new Date
		console.log p2(d.getHours())+':'+p2(d.getMinutes())+':'+p2(d.getSeconds())+' | '+prefix+' | '+data

	error: (data) -> @log '!', data
	info: (data) -> @log '=', data

	get_module: (name) ->
		for i in @modules
			if i
				if i.name is name
					return i
		null

	get_loaded: () ->
		tmp = []
		for i in @modules
			if i
				tmp.push i.name
		tmp

	load_all: () ->
		fs.readdir path.resolve(__dirname, 'modules'), (err, files) =>
			for i in files
				name = i.split(".")[0]
				extension = i.split(".")[1]
				if extension == "coffee"
					@load name
			@firstload = false

	dynamic_load: () ->
		@timeouts = {}
		fs.watch path.resolve(__dirname, 'modules'), (event, filename) =>
			delay = (ms, func) -> setTimeout func, ms

			if typeof @timeouts[filename] != "undefined"
				clearTimeout @timeouts[filename]
				delete @timeouts[filename]

			@timeouts[filename] = delay 1000, () =>
				name = filename.split(".")[0]
				extension = filename.split(".")[1]

				if extension == "coffee"
					@load name

	load: (name) ->
		try
			if name == "base_module"
				return
			module_info = @get_module name
			if module_info != null and not @firstload
				@unload name
			else if module_info != null and @firstload
				return
			module_path = path.resolve __dirname, 'modules', name+'.coffee'
			delete require.cache[module_path]
			module_object = require module_path

			module_itself = new module_object @, if @config.modules[name] then @config.modules[name] else {}

			if module_itself.info
				for i in module_itself.info.depends
					tmp = @get_module i
					if tmp == null
						@load i


			module_itself.load()

			module_info =
				module: module_itself
				name: name
				path: module_path
			@modules.push module_info

		catch e
			@error 'load: '+e

	unload: (name) ->
		try
			module_info = @get_module name
			if module_info == null
				return
			module_info.module.unload()

			pos = @modules.indexOf module_info
			if pos != -1
				@modules.splice pos, 1

		catch e
			@error 'unload: '+e

p2 = (i) -> if (i+'').length == 1 then '0'+i else i

module.exports = UNO