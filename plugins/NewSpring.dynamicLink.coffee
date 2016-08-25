###
@class Slider

@author
  NewSpring Church

@version 0.1

@note
  Creates a dynamic URL from the matching input's value

@dependencies

###
class dynamicLink
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
      queryString: params[1]
      target : @data
      href : @data.getAttribute("href")
      attr : attr

    # Setup
    @.bindEvents()

  followLink: () =>

    if typeof window isnt "undefined" and window isnt null
      
      query = document.querySelector('[' + @_properties.attr + '-value="' + @_properties._id + '"]').value
      
      if query != ''
        dynamicURL = @_properties.href + "?" + @_properties.queryString + "=" + escape(query)
      else
        dynamicURL = @_properties.href
      
      window.location = dynamicURL

  bindEvents: () =>

    # Add event listener to find the click.
    triggers = []
    triggers.push(document.querySelector('[' + @_properties.attr + '^="' + @_properties._id + '"]'))
    triggers.push(document.querySelector('[' + @_properties.attr + '-value="' + @_properties._id + '"]'))

    for trigger in triggers

      enter = (e) =>
        if e.keyCode is 13
          click(e)

      click = (e) =>
        e.preventDefault()
        @.followLink()

      if trigger.tagName is "INPUT"
        trigger.addEventListener('keydown', enter)
      else
        trigger.addEventListener('click', click)

    this

if jQuery and core?
  core.addPlugin('dynamicLink', dynamicLink, '[data-dynamic-link]' )