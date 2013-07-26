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

fs = require("fs")
path = require("path")

modman = () ->
	o = {}

	o.loaded = []
	o.available = []
	o.modulePath = ""
	o.irc = null
	o.hasInit = false

	o.init = (irc, modulePath) ->
		this.irc = irc
		this.modulePath = modulePath || irc.config.modulePath
		this.hasInit = true

		fs.watch(this.modulePath, (event, filename) =>
			console.log("MM.EVENT is "+event)
			console.log("MM.FILENAME is "+filename)
			name = filename.split(".")
			if name[1..].join(".") == "module.js"
				if event == "change" || event == "new"
					this.load(name[0])
		)

	o.refresh = () ->
		try
			tmp = []
			files = fs.readdirSync(this.modulePath)
			for i in files
				parts = i.split(".")
				if parts[1..].join(".") == "module.js"
					tmp.push(parts[0])
			this.available = tmp

		catch error
			console.log("ERROR #{error}")

	o.loadAll = () ->
		this.refresh()
		console.log(this.available)
		try
			for i in this.available
				this.load i
		catch error
			console.log("ERROR #{error}")

	o.hardReload = () ->
		this.loaded = []
		this.irc.hooks = []
		this.loadAll()

	o.isLoaded = (name) ->
		for i in this.loaded
			if i.name == name
				return true
		return false

	o.resolveName = (name) ->
		for i in this.loaded
			if i.name == name
				return i
		return null
	
	o.load = (name) ->
		try
			if this.isLoaded(name)
				this.reload(name)
			else
				pat = path.resolve(this.modulePath, name+".module.js")
				console.log(require(pat))
				module = require(pat)[name]
				module.init(this.irc)
				this.loaded.push({name: name, path: pat, module: module})
				console.log("MM.LOAD "+name)

				if this.available.indexOf(name) == -1
					this.available.push(name)

		catch error
			console.log("ERROR #{error}")

	o.unload = (name) ->
		try
			i = this.resolveName(name)
			if i != null
				pos = this.loaded.indexOf(i)
				i.module.deinit(this.irc)
				delete require.cache[i.path]
				this.loaded.splice(pos, 1)
				console.log("MM.UNLOAD "+name)
		catch error
			console.log("ERROR #{error}")

	o.reload = (name) ->
		try
			this.unload name
			this.load name
		catch error
			console.log("ERROR #{error}")

	o.reloadAll = (name) ->
		try
			for i in this.loaded
				this.reload i.name
		catch error
			console.log("ERROR #{error}")

	o.getLoaded = () ->
		tmp = []
		for i in this.loaded
			tmp.push(i.name)
		return tmp

	o.getAvailable = () ->
		this.refresh()
		return this.available


	return o

exports.modman = new modman