

###
@class Slider

@author
  James E Baxley III
  NewSpring Church

@version 0.1

@note
  Handles interactions of accordions based on data- parameters

@dependencies
  slick.js

###
class Slider
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
      start: params[1] - 1
      settings : try JSON.parse(params[2]) catch e then {}



    # Bind click ents to accordion behaviors
    @.configureSettings()

  getBreakpoints: =>
    responsive = [{
      breakpoint: 1600
      settings:
        centerMode: true
        slidesToShow: 1
      },{
      breakpoint: 1280
      settings:
        centerMode: true
        slidesToShow: 1
      },{
      breakpoint: 960
      settings:
        centerMode: true
        slidesToShow:1
      },{
      breakpoint: 480
      settings:
        centerMode: true
        slidesToShow: 1
      }
    ]

    return responsive



  configureSettings: =>

    settings = @_properties.settings


    # Do things for regular patterns here
    if settings.showTitles
      settings.customPaging = (slick, index) ->
        paging = $(slick.$slides.get(index)).find('a').attr('title') || ''
        return '<a class="slider__nav--title" >'+paging+'</a>'


    if settings.responsive
        # responsive : @.getBreakpoints()
      settings =
        centerMode: true
        centerPadding: "60px"
        slidesToShow: 3
        responsive: [
          {
            breakpoint: 768
            settings:
              arrows: true
              centerMode: true
              centerPadding: "20px"
              slidesToShow: 1
          }
          {
            breakpoint: 480
            settings:
              arrows: true
              centerMode: true
              centerPadding: "5px"
              slidesToShow: 1
          }
        ]


    @.enableSlider(settings)



  enableSlider: (settings) =>

    document.addEventListener('DOMContentLoaded', () =>

      $(@_properties.target).slick(settings).slickGoTo(@_properties.start)

    )



if jQuery and core?
  core.addPlugin('Slider', Slider, '[data-slider]' )
