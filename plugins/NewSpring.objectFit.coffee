###
@class objectFit

@author
  Edolyne Long
  NewSpring Church

@version 0.1

@note
  Current Supported Devices

###

class objectFit
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

    @.browserCheck()

  browserCheck: =>

    # Check to make sure that the browser doesn't support object-fit
    if /msie|Trident|Android\s(4\.[0-9 .]*)|\sOS\s7|Silk|(?:[6-7]\.[0-9 .]*)\sSafari/i.test(navigator.userAgent)
      #Non supported browser?  Let's change that element
      @.imageSwap()

  imageSwap: =>

    # Get the image src
    backgroundImage = @_properties.target.src

    # Get the current class name(s)
    oldClasses = @_properties.target.className

    # Replace the current IMG with the span including the old data
    @_properties.target.outerHTML = "<span class='#{oldClasses} background--fill' style='background-image: url(#{backgroundImage});'></span>"

if core?
  core.addPlugin('objectFit', objectFit, '[data-object-fit]')

navigator.userAgent.match(/(iPad|iPhone);.*CPU.*OS 7_\d/i)
