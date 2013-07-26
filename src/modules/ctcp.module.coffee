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

ctcp = () ->
	o = {}

	o.info = {}
	o.info.name = "CTCP"
	o.info.description = "CTCP replies"
	o.info.author = "Juhani Imberg"
	o.info.version = 1	

	o.hookId = -1
	o.init = (irc) ->
		o.hookId = irc.hook('CTCP', (args) ->
			msg = args.message.split(" ")
			switch msg[0]
				when "PING"
					rest = msg[1..].join(" ")
					irc.ctcp(args, 'PING '+rest)
				when "TIME"
					d = new Date()
					irc.ctcp(args, 'TIME '+d.toUTCString())
				when "VERSION"
					irc.ctcp(args, 'VERSION uno version '+irc.version)
				when "SOURCE"
					irc.ctcp(args, 'SOURCE https://github.com/JuhaniImberg/uno')
				when "FINGER"
					irc.ctcp(args, 'FINGER '+irc.config.realname+' doesn\'t idle')
		)
	o.deinit = (irc) ->
		irc.dehook(this.hookId)

	return o

exports.ctcp = new ctcp