class Base_Module
	constructor: (@uno, @config) ->
	about: () ->
		@info

	load: () ->
		for i in @hooks
			if i
				if i.once
					@uno.once i.event, (data) => i.callback(@, data)
				else
					@uno.on i.event, (data) => i.callback(@, data)

		@uno.log '+', @info.name+' ('+@info.version+')'

	unload: () ->
		for i in @hooks
			if i
				@uno.removeListener i.event, i.callback

		@uno.log '-', @info.name+' ('+@info.version+')'




module.exports = Base_Module