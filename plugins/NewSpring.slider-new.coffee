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
      attr : attr

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
      return 0.43

    if width < 1260
      return 0.29

    return 0.2

  dynamicWidthContainer: (count, containerWidth) =>
    itemSize = Math.round((containerWidth) * @.getRatio(containerWidth))
    itemMargin = parseInt(window.getComputedStyle(@_properties.children[0], null).getPropertyValue("margin-right").replace('px',''))

    width = (count * (itemSize + itemMargin)) + itemMargin

    @_properties.target.style.width = width + 'px'

  dynamicWidth: (sliderItems, containerWidth) =>
    itemSize = Math.round((containerWidth) * @.getRatio(containerWidth))
    
    for item in sliderItems
      item.style.width = itemSize + 'px'

  sliderSetup: () =>
    if typeof window isnt "undefined" and window isnt null
      containerWidth = document.querySelector('[' + @_properties.attr + '-width="' + @_properties._id + '"]').offsetWidth
      @.dynamicWidthContainer(@_properties.childElementCount, containerWidth)
      @.dynamicWidth(@_properties.children, containerWidth)

if jQuery and core?
  core.addPlugin('SliderNew', SliderNew, '[data-slider-new]' )