###

@class NewSpringPlayer

@author
	James E Baxley III
	NewSpring Church

@version 0.1

###
class Player

	###
	Constructor function runs when object gets initialized

	@param {Element} Element to be used for creating video and image fallback

	###
	constructor: (@data, attr) ->

		# Check and see if called by jQuery and convert to node
		if @data instanceof jQuery then @data = @data.get(0)

		# get id for namespace
		params = @data.attributes[attr].value.split(',')

		# clean up whitespace
		params = params.map (param) -> param.trim()

		if params.length > 3
			meta = params.splice(0, 2)
			json = params.join(',')
			params = meta.concat json


		#bind element and properties to private @_properties variable
		@_properties = {
			_id: params[0]
			#this is where we store info about the video/image
			video:
				element: @data
				klass: @data.className
				code: params[1]
			params:
				# try JSON.parse(params[2]); catch e then {}
				pcode: "E1dWM6UGncxhent7MRATc3hmkzUD"
				playerBrandingId: "ZmJmNTVlNDk1NjcwYTVkMzAzODkyMjg0"
				autoplay: true
				skin: {
					config: "http://ns.assets.s3.amazonaws.com/newspring/skin.new.json"
					inline: { shareScreen: { embed: { source: "<iframe width='640' height='480' frameborder='0' allowfullscreen src='//player.ooyala.com/static/v4/stable/4.5.5/skin-plugin/iframe.html?ec=<ASSET_ID>&pbid=<PLAYER_ID>&pcode=<PUBLISHER_ID>'></iframe>" } } }
				}
			scriptKeys:
				ooyala: "//player.ooyala.com/static/v4/stable/4.6.9/core.min.js"
				plugin: "//player.ooyala.com/static/v4/stable/4.6.9/video-plugin/main_html5.min.js"
				skin: "//player.ooyala.com/static/v4/stable/4.6.9/skin-plugin/html5-skin.js"
		}

		# Set defaults
		@_properties.params.template = @_properties.params.template || 'videoPlayer'
		@_properties.params.type = @_properties.params.type || ['ooyala', 'plugin', 'skin']
		@_properties.params.playerId = @_properties.params.playerId || 'player--ooyala'
		@_properties.params.autoPlay = @_properties.params.autoPlay || false

		# Initiating Function
		@
			.loadScripts()
			.loadModal()
			.setUpVideo()


	loadModal: =>

		Modal = core['plugins']['Modal']


		if Modal?
			if core.modal?
				if core.modal[@_properties.params.template] is undefined
					tmpl = @_properties.params.template
					core.modal[tmpl] = new Modal.model tmpl, 'data-modal-open', "preload"

			else
				core.modal = {}
				tmpl = @_properties.params.template
				core.modal[tmpl] = new Modal.model tmpl, 'data-modal-open', "preload"

		this


	###

	@function loadScripts()

	@note
		loads needed scripts on the page for embeded video

	@chainable

	###
	loadScripts: =>

		# Object containing needed scripts
		scriptArray = []

		# Set src
		if @_properties.params.type.length > 0
			for type in @_properties.params.type
				if @_properties.scriptKeys[type]
					# Create script
					script = document.createElement "script"
					script.setAttribute "src", @_properties.scriptKeys[type]
					scriptArray.push script
				else
					console.log "no script key found for #{@_properties.video.type}"
					false

		@appendScripts(scriptArray)

		this

	appendScripts: (scriptArray) =>

		callback = =>
			@.appendScripts(scriptArray)

		# Get all scripts to check against
		scripts = core.flatten document.getElementsByTagName "script"

		for scriptItem in scriptArray
			# Make sure that the script isn't currently loaded
			scrpt = scripts.filter( (attr) =>
				if attr.attributes["src"]? && attr.attributes["src"].value?
					return attr.attributes["src"].value is scriptItem.src
			)

			unless scrpt.length > 0
				if scriptItem.src.split(":")[1] is @_properties.scriptKeys.ooyala
					document.head.appendChild scriptItem
				else
					if window.OO
						document.head.appendChild scriptItem
					else
						setTimeout callback, 250

	###

	@function setUpVideo()

	@note
		Router function for video setup based on type

	@todo
		Write way to dynamically call function based on @_properties.video.type
		DO NOT USE EVAL

	@chainable

	###
	setUpVideo: =>

		# Load ooyala player on click
		if "ooyala" in @_properties.params.type
			unless @_properties.params.autoPlay
				@_properties.video.element.addEventListener "click", @.setUpOO, false
			else
				@.setUpOO()
				@_properties.video.element.addEventListener "click", @.setUpOO, false


		this



	###

	@function setUpOO()

	@note
		Setting up ooyala videos

	@todo
		Explore OO API for more powerful scripting

	@chainable

	###
	setUpOO: =>

		# See if ooyla script has loaded
		if (typeof window isnt "undefined" || window isnt null) && !window.OO

			###

			@todo
			Set up better error handling.
			Would like to have it try to load script again
			If countinues to fail then load error and send to GA

			###
			callback = =>
				@.setUpOO()

			setTimeout callback, 250


		else

			# Wait until ooyla script is ready to go
			OO.ready( =>

				# Show the modal
				core.modal[@_properties.params.template].toggleModal()
				# Create video element into player--video container based on embed code
				@_properties.video.player = OO.Player.create(
					@_properties.params.playerId,
					@_properties.video.code,
					@_properties.params
				)

				# Destroy video and report it to GA (google)
				destroy = =>
					@.reportEvent "destroyed"
					@_properties.video.player.destroy @_properties.params.playerId



				# esc function to close modal and call destroy or play and pause on keyup
				listen = (event) =>
					# if key hit is `esc` or template is closed is clicked
					if event.keyCode is 27 or core.isElement(event)

						# Destroy video
						destroy()
						if event.keyCode is 27 then core.modal[@_properties.params.template].toggleModal()

						# remove listener
						document.removeEventListener "keyup", listen, false

					# if key hit is `space` then pause or play
					else if event.keyCode is 32
						if @_properties.video.player.state is "paused"
							@_properties.video.player.play()
						else @_properties.video.player.pause()


				# Add event listeners for keyup and clicking of close button
				document.addEventListener "keyup", listen, false
				core.modal[@_properties.params.template].events.on('close', listen)

				###

				Playing events

				###
				@_properties.messages.subscribe OO.EVENTS.PLAYBACK_READY, "Video", (eventName) =>
					@.reportEvent eventName

				@_properties.messages.subscribe OO.EVENTS.PLAYED, "Video", (eventName) =>

					destroy()
					core.modal[@_properties.params.template].toggleModal()
					@.reportEvent eventName


				###

				Error Events

				###
				@_properties.messages.subscribe OO.EVENTS.PLAY_FAILED, "Video", (eventName) =>
					@.reportEvent eventName

				@_properties.messages.subscribe OO.EVENTS.BUFFERED, "Video", (eventName) =>
					@.reportEvent eventName

				###

				UI Events

				###

				# define fullscreen as not set
				fullscreen = false

				@_properties.messages.subscribe OO.EVENTS.FULLSCREEN_CHANGED, "Video", (eventName) =>

					fullscreen = !fullscreen
					if fullscreen
						eventName = "Fullscreen"
						@.reportEvent eventName

			)

		this



	###

	@function reportEvent()

	@param {String} Event name for posting to GA

	@chainable

	###
	reportEvent: (event) =>

		if ga?
			ga "send", "event", "video", event, {'page': window.location.pathname}

		this



if core?
	core.addPlugin('Player', Player, '[data-video]')
