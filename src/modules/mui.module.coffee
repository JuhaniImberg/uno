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

mui = () ->
	o = {}
	
	o.info = {}
	o.info.name = "Mui."
	o.info.description = "Responds with \"Mui.\" to people who say \"Mui.\""
	o.info.author = "Juhani Imberg"
	o.info.version = 1	

	o.lastTime = 0
	o.hookId = -1
	o.init = (irc) ->
		o.hookId = irc.hook('PRIVMSG', (args) ->
			if args.message.toLowerCase().substring(0,4) == "mui."
				now = Date.now()
				if now - 10000 < o.lastTime
					return
				o.lastTime = now
				if args.message.toLowerCase().split(" ")[1] == irc.config.nick
					irc.send('PRIVMSG', args.respond, ':Mui. '+args.sender)
				else
					irc.send('PRIVMSG', args.respond, ':Mui.')
		)
	o.deinit = (irc) ->
		irc.dehook(this.hookId)

	return o

exports.mui = new mui