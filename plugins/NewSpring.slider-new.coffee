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

    if typeof window isnt "undefined" and window isnt null
      itemSize = (window.innerWidth - 30) * @.getRatio(window.innerWidth)
      itemSize = itemSize + 30
      width = count * itemSize

      @data.style.width = width + 'px'

  dynamicWidth: (sliderItems) =>

    if typeof window isnt "undefined" and window isnt null
      itemSize = (window.innerWidth - 40) * @.getRatio(window.innerWidth)

      for item in sliderItems
        item.style.width = itemSize + 'px'

  sliderSetup: () =>

    @.dynamicWidthContainer(@data.childElementCount)
    @.dynamicWidth(@data.getElementsByClassName('slider__item-new'))

if jQuery and core?
  core.addPlugin('SliderNew', SliderNew, '[data-slider-new]' )