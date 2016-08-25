###
@class relocateObject

@author
  Edolyne Long
  NewSpring Church

@version 0.1

@note
  Abolish the bots from parts that we don't want crawled.
  Important: The items relocated will be displayed in reverse order.
###

class relocateObject
  realSelf = this
  constructor: (@data, attr) ->

    # Get data from attribute
    params = @data.attributes[attr].value.split(',')

    params = params.map (param) -> param.trim()
    # [todo] - write better string to value and array method
    # solution for arrays in params object
    if params.length > 3
      meta = params.splice(0, 2)
      json = params.join(',')
      params = meta.concat json

    # Define properties
    @_properties = {
      _id: params[0]
      target : @data
      relocateTo : params[1].trim()
      attr: attr
      bot : /RogerBot|aolbuild|baidu|bingbot|bingpreview|duckduckgo|adsgot-google,mediapertners-google|googlebot|teoma|slurp|yahoo! Slurp|yandex|msnbot|facebookexternalhit|twitterbot/i.test(navigator.userAgent)
    }

    # Check for bot
    # List was found at: https://perishablepress.com/list-all-user-agents-top-search-engines/
    # RogerBot added to be able to test in SeoMoz tools

    unless @_properties.bot
      @.relocateMarkup()

  relocateMarkup: =>

    relocatePoint = document.querySelectorAll("#{@_properties.relocateTo}")[0]

    relocatePoint.insertBefore(@_properties.target, relocatePoint.firstChild)


if core?
  core.addPlugin('relocateObject', relocateObject, '[data-relocate-object]')
