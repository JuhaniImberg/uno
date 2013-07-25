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

url = () ->
	o = {}

	o.info = {}
	o.info.name = "URL"
	o.info.description = "Resolves titles of URLs"
	o.info.author = "Juhani Imberg"
	o.info.version = 1

	o.parseUrl = (msg) ->
		regex = /((http|https)?:\/\/[^\s]+)/g
		return msg.match(regex)
	
	o.hookId = -1

	o.init = (irc) ->
		this.hookId = irc.hook('PRIVMSG', (args) ->
			msg = args.message
			url = o.parseUrl(msg)
			if url != null
				url = url[0]+""
				urlObj = irc.url.parse(url)
				console.log(typeof urlObj.port == null)
				if typeof urlObj.port == "undefined"
					console.log(urlObj.protocol)
					if urlObj.protocol == "https:"
						urlObj.port = 443
					else
						urlObj.port = 80
				args2 = {host: urlObj.hostname, path: urlObj.path, port: urlObj.port};
				console.log(args2)
				proto = urlObj.protocol.split(":")[0]
				irc[proto].request(args2, (res) ->
					str = ""
					res.on('data', (c) -> str += c)

					res.on('end', () ->
						body = str
						try
							reg = /<title[^>]*>([^<]+)<\/title>/im
							title = body.match(reg)[0]+""
							title = title.split(">")[1]
							title = title.split("</")[0]
							console.log(title)
							irc.send('PRIVMSG', args.respond,
								':{'+irc.colorize.escape('title','white')+': \''+unescape(title)+'\'}'
							)
						catch error
							console.log("ERROR #{error}")
					)
				).end()
		)

	o.deinit = (irc) ->
		irc.dehook(this.hookId)

	return o

exports.url = new url