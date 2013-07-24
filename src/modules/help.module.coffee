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

help = () ->

	getInfo = (irc, what) ->
		for i in irc.modules
			if i.name == what
				return i.module.info.name+": "+i.module.info.description+"
 Author: "+i.module.info.author+" (V"+i.module.info.version+")"

	o = {}

	o.info = {}
	o.info.name = "Help"
	o.info.description = "Helps users with the bot"
	o.info.author = "Juhani Imberg"
	o.info.version = 1	
	
	o.hookId = -1
	o.init = (irc) ->
		o.hookId = irc.hook('PRIVMSG', (args) ->
			msg = args.message.toLowerCase().split(" ")
			prefix = irc.config.commandPrefix
			if msg[0] == prefix+"help" || msg[0] == prefix+"info"

				mods = []
				for i in irc.modules
					mods.push(i.name)

				if msg[1]
					if mods.indexOf(msg[1]) != -1
						irc.send('PRIVMSG', args.respond,
							getInfo(irc, msg[1]))
				else
					mods = mods.join(", ")
					irc.send('PRIVMSG', args.respond, 
						'loaded modules: '+mods)
					irc.send('PRIVMSG', args.respond, 
						'additional info: '+prefix+'info [modules name]')
					
					
		)
	o.deinit = (irc) ->
		irc.dehook(this.hookId)

	return o

exports.help = new help