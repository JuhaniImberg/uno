mui = () ->
	o = {}
	o.lastTime = 0
	o.hookId = -1
	o.init = (irc) ->
		o.hookId = irc.hook('PRIVMSG', (args) ->
			if args.message.toLowerCase().substring(0,4) == "mui."
				now = Date.now()
				if now - 10000 < o.lastTime
					return
				o.lastTime = now
				rec = args.respond
				if args.message.toLowerCase().split(" ")[1] == irc.config.nick
					irc.send('PRIVMSG', rec, ':Mui. '+args.sender)
				else
					irc.send('PRIVMSG', rec, ':Mui.')
		)
	o.deinit = (irc) ->
		irc.dehook(this.hookId)

	return o

exports.mui = new mui