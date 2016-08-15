###
@class noBots

@author
  Edolyne Long
  NewSpring Church

@version 0.1

@note
  Abolish the bots from parts that we don't want crawled
###

class noBots
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
    }

    # Check for bot
    # List was found at: https://perishablepress.com/list-all-user-agents-top-search-engines/
    # RogerBot added to be able to test in SeoMoz tools

    if /RogerBot|aolbuild|baidu|bingbot|bingpreview|duckduckgo|adsgot-google,mediapertners-google|googlebot|teoma|slurp|yahoo! Slurp|yandex|msnbot|facebookexternalhit|twitterbot/i.test(navigator.userAgent)
      @.removeSection()

  removeSection: =>

    @_properties.target.outerHTML = ""

if core?
  core.addPlugin('userAgent', userAgent, '[data-no-bots]')
