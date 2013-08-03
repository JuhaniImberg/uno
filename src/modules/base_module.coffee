class Base_Module
	constructor: (@uno, @config) ->
		@loaded_hooks = []
	about: () ->
		@info

	load: () ->
		if @hooks
			for i in @hooks
				if i
					callback = (data) => i.callback(@, data)
					if i.once
						@uno.once i.event, callback
					else
						@uno.on i.event, callback
					@loaded_hooks.push {event: i.event, callback: callback}

		@uno.log '+', @info.name+' ('+@info.version+')'

	unload: () ->
		for i in @loaded_hooks
			if i
				@uno.removeListener i.event, i.callback

		@uno.log '-', @info.name+' ('+@info.version+')'




module.exports = Base_Module