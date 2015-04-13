###

@class NewSpringBackgroundPlayer

@author
  James E Baxley III
  NewSpring Church

@version 0.9

@dependencies
  NewSpring.Utilities.js


  [todo] - add in namespacing following plugin architecture rules

###
class BackgroundPlayer


  ###
  Constructor function runs when object gets initialized

  @param {Element} Element to be used for creating video and image fallback

  ###
  constructor: (@data, attr) ->

    # Check and see if called by jQuery and convert to node
    if @data instanceof jQuery then @data = @data.get(0)

    params = @data.attributes[attr].value.split(/[,](?=[^\]]*?(?:\[))/g)

    # clean up whitespace
    params = params.map (param) -> param.trim()

    if params.length > 3
      meta = params.splice(0, 2)
      json = params.join(',')
      params = meta.concat json

    videos = params[1].replace(/[\[\]']+/g,'').split(',')
    videos = videos.map (param) -> param.trim()

    #bind element and properties to private @_properties variable
    @_properties =
      _id: params[0]
      #bind parent element
      parent: @.data.parentElement
      #this is where we store info about the video/image
      bg:
        element: @data
        klass: @data.className
      videos: videos


    ###

    Check if element is in view
    If it is, then go to @determineAssetToLoad and remove listener

    ###
    seeIfInView = =>

      if core.isElementInView(@data)

        # callback to make sure user really intends to view content
        # prevents accidental firing on scrolling past
        callback = =>

          if core.isElementInView(@data)
            window.removeEventListener('scroll', seeIfInView, false)
            @.determineAssetToLoad()
            false
          else

            ###

            @todo write better way of handling scrolling past

            ###
            # remove related event listener and add a new one back
            window.removeEventListener('scroll', seeIfInView, false)
            window.addEventListener('scroll', seeIfInView, false)

        # SetTimeout to prevent false calls on scrolling
        setTimeout callback, 500

        # remove inital eventlistener to scope a new one inside the timeout function
        window.removeEventListener('scroll', seeIfInView, false)


    ###

    Check to see if the element is in view before doing anything
    If not in view, bind resize to check and see when in view
    If in view then go to @determineAssetToLoad

    ###

    if core.isElementInView(@data)
      @.determineAssetToLoad()
    else
      debounce = core.debounce seeIfInView
      window.addEventListener('scroll', seeIfInView, false)




  ###

  @function getParentHeight()

  @return {Value} height of parent container

  ###
  getParentHeight: =>
    @_properties.parent.clientHeight



  ###

  @function getParentWidth()

  @return {Value} width of parent container

  ###
  getParentWidth: =>
    @_properties.parent.clientWidth



  ###

  @function determineAssetToLoad()

  @note
    Calls @determineDesiredPositioning with data type
    Calls @setUpImg if a mobile device
    Calls @setUpVideo if video is possible

  @chainable

  ###
  determineAssetToLoad: =>

    if core.isMobile()
      # Turned off for launch until panning is built
      # @.determineDesiredPositioning('img').setUpImg()
    else
      @.determineDesiredPositioning('video').setUpVideo()

    this



  ###

  @function determineDesiredPositioning()

  @note
    Add positioning information from data attributes to @_properties object

  @chainable

  ###
  determineDesiredPositioning: (type) =>

    # get position info
    positioning = @_properties.bg.element.getAttribute "data-#{type}-position"

    # Check to see if position info is set
    if positioning?
      # split CSV to array
      positioning = positioning.split ","

      # If one value set use it for both x and y axis
      if positioning.length is 1
        @_properties.bg.xaxis = positioning[0].replace /(^\s+|\s+$)/g, ""
        @_properties.bg.yaxis = positioning[0].replace /(^\s+|\s+$)/g, ""
      # If two values are set, use the first for x and second for y (eg: center, bottom)
      else
        @_properties.bg.xaxis = positioning[0].replace /(^\s+|\s+$)/g, ""
        @_properties.bg.yaxis = positioning[1].replace /(^\s+|\s+$)/g, ""
    # no position info set, defaults to center
    else
      @_properties.bg.xaxis = "center"
      @_properties.bg.yaxis = "center"

    this



  ###

  @function buildElement()

  @param {String} Kind of element to build (img or video)

  @return {Element} Built oject or video

  @note
    Adds element to the DOM

  ###
  buildElement: (type) =>

    # Make sure parent is set to relative if not set already
    if @_properties.parent.style.position = ""
      @_properties.parent.style.position = "relative"

    # Create empty assets (either img or video)
    asset = document.createElement type

    unless type is "video"
      # Set src
      asset.src = @_properties.bg.element.getAttribute "data-background-#{type}"
    else

      for video in @_properties.videos

        # Create new source type for each asset
        source = document.createElement "source"
        source.src = video.trim()
        source.type = "video/#{video.substr(video.lastIndexOf('.') + 1)}"

        # Add to video element
        asset.appendChild source

    # Store classname in local object
    @_properties.bg.element.klass = @_properties.bg.element.className

    # Set classes from skeleton object
    asset.className = @_properties.bg.element.klass

    # Insert into DOM
    @_properties.parent.insertBefore asset, @_properties.bg.element

    # Move skeleton to object for deletion on asset load
    @_properties.bg.root = @_properties.bg.element

    # Make element in object the new asset
    @_properties.bg.element = asset

    # return asset
    asset



  ###

  @function setCSS()

  @note
    Makes sure asset is fully filling container element
    Also makes sure video is in background with z-index

  @chainable

  ###
  setCSS: =>
    # Parent styles
    @_properties.parent.style.overflow = "hidden"

    # Element styles
    @_properties.bg.element.style.display = "block"
    @_properties.bg.element.style.position = "absolute"
    @_properties.bg.element.style.objectFit = "cover"
    @_properties.bg.element.style.height = "auto"

    @_properties.bg.element.style.minWidth = "100%"
    @_properties.bg.element.style.minHeight = "100%"
    @_properties.bg.element.style.zIndex = "-5px"
    @_properties.bg.element.style.top = "0"
    @_properties.bg.element.style.bottom = "0"
    @_properties.bg.element.style.left = "0"
    @_properties.bg.element.style.right = "0"

    if core.isMobile() then @_properties.bg.element.style.width = "auto"

    this



  ###

  @function setUpImg()

  @note
    sets up img for mobile devices and waits until it is loaded before moving on

  @chainable

  ###
  setUpImg: =>

    # Get src of img or .gif
    img_src = @_properties.bg.element.getAttribute "data-background-img"

    # If fallback is listed, build img for it
    if img_src?

      # create img
      img = @.buildElement('img')

      ###

      @function startSizing()

      @note
        fires @setCSS to ensure styles
        fires @matchParentSize for inital size
        fires @bindResize for debounce based resizing

      @chainable

      ###
      startSizing = =>
        @.setCSS().matchParentSize().bindResize()

        img.removeEventListener 'load', startSizing, false

        # remove skeleton element (still in @_properties if needed)
        @_properties.parent.removeChild @_properties.bg.root

        this

      # Checks to see if image has loaded, if so fire startSizing
      img.addEventListener 'load', startSizing, false



    this



  ###

  @function setUpVideo()

  @note
    sets up video for non-mobile devices and waits until it is loaded before moving on

  @chainable

  ###
  setUpVideo: =>

    # create video
    video = @.buildElement('video')

    # hide video until ready for viewing
    video.style.display = "none"

    ###

    @function startPlaying()

    @note
      fires @setCSS to ensure styles
      fires @matchParentSize for inital size
      fires @bindResize for debounce based resizing
      fires @startPlaying to play video

    @chainable

    ###
    startSizing = =>

      @.setCSS().matchParentSize().bindResize().startPlaying()

      video.removeEventListener('canplay', startSizing, false)

      # remove skeleton element (still in @_properties if needed)
      @_properties.parent.removeChild @_properties.bg.root


      this

    # Checks to see if video has loaded, if so fire startPlaying
    video.addEventListener('canplay', startSizing, false)



  ###

  @function startPlaying()

  @note
    puts video into loop
    mutes video
    starts video playing

  @chainable

  ###
  startPlaying: =>

    # Set loop to true
    @_properties.bg.element.loop = true

    # Mute video
    @_properties.bg.element.volume = 0

    # Start playing video
    if @_properties.bg.element.paused then @_properties.bg.element.play()

    # Debounced scrolling listner to see if video should still be playing
    debounce = core.debounce @.shouldPlay

    window.addEventListener('scroll', debounce, false)

    this



  ###

  @function shouldPlay()

  @note
    checks to see if video is in view, if it is then it plays, otherwise it pauses video

  @chainable

  ###
  shouldPlay: =>

    # is video in view?
    if core.isElementInView(@_properties.bg.element)

      # if so, see if paused and start playing
      if @_properties.bg.element.paused
        @_properties.bg.element.play()

    else

      # otherwise, pause video to not kill CPU
      unless @_properties.bg.element.paused
        @_properties.bg.element.pause()

    this



  ###

  @function bindResize()

  @note
    uses debounce and resize binding to maintain sizing

  @chainable

  ###
  bindResize: (type) =>
    debounce = core.debounce @.testIfResized

    window.addEventListener "resize", debounce, false

    this



  ###

  @function testIfResized()

  @note
    checks to see if resize event is genuine

  @chainable

  ###
  testIfResized: =>

    if @_properties.wid?
      if @_properties.wid = window.innerWidth
        @.setPositionOffset()
      else
        @.matchParentSize()
    else
      @.matchParentSize()

    this



  ###

  @function matchParentSize()

  @note
    matches element to parent size while keeping original assets aspect ratio

  @chainable

  ###
  matchParentSize: =>

    # Get parent height
    parentHeight = @.getParentHeight()

    # Get parent width
    parentWidth = @.getParentWidth()

    ###

    Determine size of intended asset while load is happening

    ###
    if @_properties.bg.element.videoHeight?
      elementHeight = @_properties.bg.element.videoHeight
      elementWidth = @_properties.bg.element.videoWidth
    else
      elementHeight = @_properties.bg.element.naturalHeight
      elementWidth = @_properties.bg.element.naturalWidth

    # Get aspect ratio
    aspectRatio = (elementWidth / elementHeight)

    # Determine if element is wider than parent
    wide = aspectRatio <= (parentWidth / parentHeight)

    # see if element needs to be adjusted for width or height
    if wide
      @_properties.bg.element.width = parentWidth
      @_properties.bg.element.height = (parentWidth*elementHeight)/elementWidth
    else
      @_properties.bg.element.height = parentHeight
      @_properties.bg.element.width = (parentHeight*elementWidth)/elementHeight

    #Set Width to check against for incorrectly called mobile resize
    if core.isMobile() then @_properties.wid = window.innerWidth

    # Fires offset function for positioning of element
    @.setPositionOffset()

    this



  ###

  @function setPositionOffset()

  @note
    Uses margin left and margin top to handle offset

  @chainable

  ###
  setPositionOffset: =>

    # Get parent height
    parentHeight = @.getParentHeight()

    # Get parent width
    parentWidth = @.getParentWidth()

    # Offset on x axis
    switch @_properties.bg.xaxis
      when "left"
        @_properties.bg.element.style.marginLeft = 0
      when "right"
        @_properties.bg.element.style.marginLeft = "#{-( @_properties.bg.element.width - parentWidth) }px"
      else
        @_properties.bg.element.style.marginLeft = "#{-( (Math.abs(@_properties.bg.element.width - parentWidth) )/2 )}px"

    # Offset on y axis
    switch @_properties.bg.yaxis
      when "top"
        @_properties.bg.element.style.marginTop = 0
      when "bottom"
        @_properties.bg.element.style.marginTop =  "#{ -( @_properties.bg.element.height - parentHeight) }px"
      else
        @_properties.bg.element.style.marginTop = "#{-( ( (@_properties.bg.element.height - parentHeight ) )/2 )}px"

    this




if core?
  core.addPlugin('BackgroundPlayer', BackgroundPlayer, '[data-background-video]')
