###
@class userAgent

@author
  Edolyne Long
  NewSpring Church

@version 0.1

@note
  Current Supported Devices
    iOS
    Android
    Kindle
###

class userAgent
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
      targetDevice : params[1]
    }

    # Check for mobile
    if /Mobile|Android|Silk/i.test(navigator.userAgent)
      @.setDevice()

  setDevice: =>

    ## Find the current device
    if /iPhone|iPad|iPod/i.test(navigator.userAgent)
      currentDevice = 'ios'
    else if /Silk/i.test(navigator.userAgent)
      currentDevice = 'kindle'
    else if /Android|Nexus/i.test(navigator.userAgent)
      currentDevice = 'android'

    if currentDevice is @_properties.targetDevice
      core.removeClass @_properties.target, "visuallyhidden"

    else if currentDevice isnt @_properties.targetDevice
      core.addClass @_properties.target, "visuallyhidden"

if core?
  core.addPlugin('userAgent', userAgent, '[data-user-agent]')
