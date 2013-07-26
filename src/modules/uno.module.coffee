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

uno = () ->
	o = {}

	o.info = {}
	o.info.name = "UNO management"
	o.info.description = "UNO management services"
	o.info.author = "Juhani Imberg"
	o.info.version = 1	
	
	o.hookId = -1
	o.init = (irc) ->
		o.hookId = irc.hook('PRIVMSG', (args) ->
			msg = args.message.toLowerCase().split(" ")
			prefix = irc.config.commandPrefix
			if msg[0] == prefix+"uno"
				if irc.modman.god(args.sender)
					msg[1] = msg[1] || ""

					switch msg[1]
						when ""
							irc.respond(args, "Yes my master?")
						when "reload", "r"
							irc.respond(args, "Reloading plugins")
							irc.modman.reloadAll()
						when "reset", "hardreload", "hr", "hardreset"
							irc.respond(args, "Hardreloading plugins")
							irc.modman.hardReload()
						when "quit", "q"
							irc.send("QUIT Goodbye cruel world!")
							process.exit(0);
						when "join", "j"
							if typeof msg[2] == "string"
								irc.send('JOIN '+msg[2])
						when "part", "p"
							if typeof msg[2] == "string"
								irc.send('PART '+msg[2])
						when "load", "l"
							if typeof msg[2] == "string"
								irc.modman.load(msg[2])
						when "disable", "d"
							if typeof msg[2] == "string"
								irc.modman.disable(msg[2])
						when "enable", "e"
							if typeof msg[2] == "string"
								irc.modman.enable(msg[2])

				else
					irc.respond(args, 'You are not worthy of speaking directly to me')
				
		)
	o.deinit = (irc) ->
		irc.dehook(this.hookId)

	return o

exports.uno = new uno