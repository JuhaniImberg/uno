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

god = () ->
	o = {}

	o.info = {}
	o.info.name = "god"
	o.info.description = "Provides god services"
	o.info.author = "Juhani Imberg"
	o.info.version = 1

	o.gods = []
	o.pending = []

	o.hookId1 = -1
	o.hookId2 = -1

	o.irc = null

	o.add = (name) ->
		if typeof name != "string"
			return "invalid argument"

		pos = this.gods.indexOf(name)
		if pos > -1
			return 'already a god'

		pos = this.pending.indexOf(name)
		if pos == -1
			this.pending.push(name)
			return '{pending: ['+o.pending.join(", ")+']}'
			try
				o.irc.send('PRIVMSG NickServ STATUS '+name)
			catch error

		else
			return 'already pending'


	o.remove = (name) ->
		if typeof name != "string"
			return "invalid argument"

		pos = this.gods.indexOf(name)

		if pos != -1
			this.gods.splice(pos, 1)
			return '{gods: ['+o.gods.join(", ")+']}'
		else
			return 'not a god'

	o.auth = (name) ->
		pos = this.gods.indexOf(name)
		if pos == -1
			return false
		return true

	o.refresh = () ->
		try
			for i in o.pending
				o.irc.send('PRIVMSG NickServ STATUS '+i)
			for i in o.gods
				o.irc.send('PRIVMSG NickServ STATUS '+i)
		catch error


	o.init = (irc) ->

		o.irc = irc

		for i in irc.config.modules.god.auto||[]
			o.add(i)
		o.refresh()

		o.hookId1 = irc.hook('PRIVMSG', (args) ->
			msg = args.message.toLowerCase().split(" ")
			prefix = irc.config.commandPrefix
			if msg[0] == prefix+"god" || msg[0] == prefix+"gods"
				msg[1] = msg[1] || "list"
				switch msg[1]
					when ""
						irc.respond(args, '{}')
					when "pending"
						irc.respond(args, '{pending: ['+o.pending.join(", ")+']}')
					when "list"
						irc.respond(args, '{gods: ['+o.gods.join(", ")+']}')
					when "add"
						if irc.modman.god(args.sender) #if o.auth(args.sender)
							irc.respond(args, o.add(msg[2]))
						else
							irc.respond(args, 'you have no rights')
					when "remove"
						if irc.modman.god(args.sender) #if o.auth(args.sender)
							irc.respond(args, o.remove(msg[2]))
						else
							irc.respond(args, 'you have no rights')
					when "refresh"
						o.refresh()
						irc.respond(args, 'refreshing pending gods')
					when "help"
						irc.respond(args, 'pending - list of pending gods, list - list of verified gods, add - add a pending god, remove - remove a god, refresh - refreshes god status, help - this')
		)

		o.hookId2 = irc.hook('NOTICE', (args) ->
			msg = args.what.split(" ")
			if msg[0] == "STATUS" && args.who == "NickServ"
				pos = o.pending.indexOf(msg[1])
				if pos != -1
					if msg[2] == "3"
						o.pending.splice(pos, 1)
						o.gods.push(msg[1])
				else
					if msg[2] != "3"
						o.gods.splice(pos, 1)
						o.pending.push(msg[1])
		)

	o.deinit = (irc) ->
		irc.dehook(this.hookId1)
		irc.dehook(this.hookId2)

	return o

exports.god = new god