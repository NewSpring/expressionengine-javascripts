###
@class FullScreen

@author
  James E Baxley III
  NewSpring Church

@version 0.1

@note
  used to turn an element into a full screen element
  Resize is bound

###

class FullScreen

  constructor: (@data, attr) ->


    # Check and see if called by jQuery and convert to node
    if @data instanceof jQuery then @data = @data.get(0)

    # Get data from attribute
    params = @data.attributes[attr].value.split(',')

    params = params.map (param) -> param.trim()


    @_properties = {
      target : @data
      height : params[1]
      width : params[2]
      id: params[0]

    }

    @.bindResize @_properties.target


  expandElement: =>



    windowHeight = window.innerHeight
    windowWidth = window.innerWidth

    if @_properties.height isnt `undefined`
      acutalHeight = windowHeight - @_properties.height
    else acutalHeight = windowHeight

    unless @_properties.width is 'false'
      @_properties.target.style.width = windowWidth + "px"

    unless @_properties.height is 'false'
      @_properties.target.style.height = acutalHeight + "px"

      if @_properties.target.tagName is 'IFRAME'
        @_properties.target.height = acutalHeight



    this



  bindResize: (element) =>

    debounce = null

    debounce ?= new Debouncer @.expandElement

    window.addEventListener "resize", debounce, false

    @.expandElement()



if core?
  core.addPlugin('FullScreen', FullScreen, '[data-fullscreen]')
