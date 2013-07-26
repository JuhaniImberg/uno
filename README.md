UNO
===

Uno Not One - modular IRC bot in CoffeeScript & node.js

Usage
-----

	node lib/uno.js

Dependencies
------------

	node.js
	coffeescript (development only)

Included modules
----------------

	ctcp
		ctcp replies
	dice
		dice throwing
	god
		authetication for dangerous commands (requires NickServ identify)
	hello
		welcomes users to a channel
	help
		provices help
	mui
		responds with Mui. to people who say Mui.
	ping
		same as Mui. but with ping
	uno
		management commands
	url
		title resolving for urls

	(last updated for commit 21)

Configuring
-----------

	config.json

	nick - username for irc
	realname - realname
	network - address:port
	encoding - encoding
	autojoin - autojoined channels
	commandPrefix - how do commands start
	message
		part - part message
		quit - quit message
	disabledModules - what modules are disabled
	modules
		god
			auto - who are auto godded