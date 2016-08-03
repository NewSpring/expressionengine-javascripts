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

  sliderSetup: =>
  
    # Get screen width
    screenWidth = window.innerWidth

    # Get quantity of children elements
    childCount = @data.childElementCount

    # Create array of children elements
    sliderItems = @data.getElementsByClassName('slider__item-new')

    # Set element widths/gutters
    if screenWidth >= 1024
      cardWidth = screenWidth * .333
      gutter = 20
    else if screenWidth >= 480
      cardWidth = screenWidth * .4
      gutter = 20
    else
      cardWidth = screenWidth * .75
      gutter = 16

    # Loop through children element array
    for item in sliderItems
      # Set card width
      item.style.width = cardWidth + 'px';
      # Set card gutter
      item.style.marginRight = gutter + 'px';

    # Calculate slider width
    sliderWidth = (cardWidth + gutter) * childCount

    # Set slider width
    @data.style.width = sliderWidth + 'px';
    # Set slider left margin
    @data.style.marginLeft = gutter + 'px';


if jQuery and core?
  core.addPlugin('SliderNew', SliderNew, '[data-slider-new]' )