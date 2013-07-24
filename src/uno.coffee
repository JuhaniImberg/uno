###
Copyright (c) 2013 Juhani Imberg

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

net = require("net")
sys = require("sys")
fs = require("fs")
path = require("path")
colorize = require("./colorize.js")['colorize']
http = require("http")
https = require("https")
url = require("url")

stdin = process.openStdin()

stdin.addListener("data", (d) ->
	message = d.toString().replace(/(\r\n|\n|\r)/gm,"") #.substring(0, d.length-2)
	if message.indexOf(".") == 0
		irc.command(message.substring(1))
	else
		irc.send(message)
)

irc = {buffer: "", hooks: [], hid: 0}

irc.colorize = colorize
irc.http = http
irc.https = https
irc.url = url

irc.config = {}

irc.loadConfig = (callback) ->
	config = require(path.resolve(__dirname,'..','config.json'))
	irc.config = config
	irc.config.modulePath = path.resolve(__dirname,'modules')
	callback()


irc.modules = []

irc.loadAllModules = () ->
	files = fs.readdirSync(irc.config.modulePath)
	for i in files
		name = i.split(".")[0]
		irc.loadModule(name)

irc.loadModule = (name) ->
	try
		console.log("LOADING MODULE "+name)
		module = require(path.resolve(
			irc.config.modulePath, name+".module.js"
		))[name]
		module.init(irc)
		this.modules.push({name: name, module: module})
		console.log("LOADED MODULE "+name)
	catch error
		console.log("ERROR #{error}")

irc.reloadModules = () ->
	console.log("RELOADING MODULES")
	for i in this.modules
		try
			console.log("RELOADING MODULE "+i.name)

			i.module.deinit(irc)
			delete require.cache[path.resolve(
				irc.config.modulePath, i.name+".module.js"
			)]

			module = require(path.resolve(
				irc.config.modulePath, i.name+".module.js"
			))[i.name]

			module.init(irc)
			i.module = module

			console.log("RELOADED MODULE "+i.name)
		catch error
			console.log("ERROR #{error}")	

irc.hook = (action, callback) ->
	this.hooks.push({callback: callback, action: action, hookId: ++irc.hid})
	return irc.hid

irc.dehook = (hookId) ->
	offset = 0
	for i in this.hooks
		if i.hookId == hookId
			break
		offset++
	if this.hooks[offset].hookId = hookId
		this.hooks.splice(offset,1)

irc.fire = (action, args) ->
	for i in this.hooks
		try
			if i.action == action
				i.callback(args)
		catch error
			console.log("ERROR #{error}")

irc.command = (com) ->
	console.log("command "+com)
	com = com.split(" ")
	command = com[0].toLowerCase()
	args = com[1..]
	switch command
		when 'q', 'e', 'quit', 'exit'
			irc.send("QUIT")
			process.exit(0);
		when 'c', 'reconnect', 'connect'
			irc.connect()
		when 'r', 'reload', 'reloadmodules'
			irc.reloadModules()
		when 'name', 'nick', 'rename', 'renick'
			irc.name(args[0])
		when 'load', 'l'
			irc.loadModule(args[0])
		when 'join', 'j'
			irc.send('JOIN',args[0])
		when 'hr', 'hardreset'
			irc.modules = []
			irc.hooks = []
			irc.loadAllModules()

irc.name = (newName) ->
	this.send('NICK '+newName)

irc.connect = () ->
	this.socket.setEncoding(this.config.encoding)
	this.socket.setNoDelay()

	a = this.config.network.split(":")
	port = a[1]
	addr = a[0]

	this.socket.connect(port, addr)
 
irc.send = (arg1) ->
	message = []
	for i in arguments
		if i
			message.push(i)

	message = message.join(' ')

	sys.puts('< '+message)
	message = message + "\r\n"
	this.socket.write(message, this.config.encoding)

irc.parse = (message) ->
	match = message.match(/(?:(:[^\s]+) )?([^\s]+) (.+)/)
	parsed = {prefix: match[1], command: match[2]}

	params = match[3].match(/(.*?) ?:(.*)/)
	if params
		params[1] = if params[1] then params[1].split(' ') else []
		params[2] = if params[2] then [params[2]] else []
		params = params[1].concat(params[2])
	else
		params = match[3].split(' ')

	parsed.params = params
	return parsed

irc.socket = new net.Socket

irc.socket.on('connect', () ->
	irc.send('NICK '+irc.config.nick)
	irc.send('USER',irc.config.nick,'0 *:'+irc.config.nick,
	irc.config.realname)
	for i in irc.config.autojoin
		irc.send('JOIN',i)
)

irc.socket.on('data', (data) ->
	this.buffer = this.buffer + data
	while this.buffer.length > 0
		offset = this.buffer.indexOf("\r\n")
		if offset < 0
			return

		message = this.buffer.substr(0, offset)
		this.buffer = this.buffer.substr(offset + 2)
		sys.puts('> '+message)

		message = irc.parse(message)
		if message != false
			irc.handleMessage(message)
)

irc.handleMessage = (message) ->
	console.log(message)
	switch message.command
		when 'PING'
			this.send('PONG', ':'+message.params[0])
		when 'PRIVMSG'
			chat =  message.params[1]
			reciever = message.params[0]
			sender = message.prefix.split("!")[0].replace("~","").substring(1)
			isChannel = reciever.indexOf("#") == 0
			respond = if isChannel then reciever else sender

			args = {
				message: chat,
				sender: sender,
				reciever: reciever,
				isChannel:isChannel,
				prefix: message.prefix,
				respond: respond
			}

			irc.fire('PRIVMSG', args)

		when 'JOIN'
			where = message.params[0]
			who = message.prefix.split("!")[0].replace("~","").substring(1)
			args = {
				where: where,
				who: who
			}

			irc.fire('JOIN', args)

		when 'PART'
			where = message.params[0]
			why = message.params[1]
			who = message.prefix.split("!")[0].replace("~","").substring(1)
			args = {
				where: where,
				who: who,
				why: why
			}

			irc.fire('PART', args)

irc.loadConfig(() ->
	irc.loadAllModules()
	irc.connect()
)