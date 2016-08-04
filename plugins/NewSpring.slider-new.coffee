###
@class Slider

@author
  NewSpring Church

@version 0.1

@note
  Handles sizing of sliders & child elements

@dependencies

###
class SliderNew
  constructor: (@data, attr) ->
    # Get data from attribute
    params = @data.attributes[attr].value.split(',')

    params = params.map (param) -> param.trim()

    if params.length > 3
      meta = params.splice(0, 2)
      json = params.join(',')
      params = meta.concat json


    # Define properties
    @_properties =
      _id: params[0]
      target : @data
      childElementCount : @data.childElementCount
      children : @data.children

    # Setup Slider
    @.sliderSetup()

    # Bind to Window Resize
    window.addEventListener('resize', @.sliderSetup);

  getRatio: (width) =>

    if width < 480
      return 0.8

    if width < 768
      return 0.6

    if width < 1025
      return 0.3

    return 0.2

  dynamicWidthContainer: (count) =>
    itemSize = Math.round((window.innerWidth) * @.getRatio(window.innerWidth))
    itemMargin = parseInt(window.getComputedStyle(@_properties.children[0], null).getPropertyValue("margin-right").replace('px',''))

    width = count * (itemSize + itemMargin)
    console.log width

    @_properties.target.style.width = width + 'px'

  dynamicWidth: (sliderItems) =>
    itemSize = Math.round((window.innerWidth) * @.getRatio(window.innerWidth))
    
    console.log itemSize

    for item in sliderItems
      item.style.width = itemSize + 'px'

  sliderSetup: () =>
    if typeof window isnt "undefined" and window isnt null
      @.dynamicWidthContainer(@_properties.childElementCount)
      @.dynamicWidth(@_properties.children)

if jQuery and core?
  core.addPlugin('SliderNew', SliderNew, '[data-slider-new]' )