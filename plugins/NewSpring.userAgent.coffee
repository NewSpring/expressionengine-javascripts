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
    Anchored
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
      userAgentLinks : document.querySelectorAll('[data-user-agent]')
    }

    # Check for mobile
    if /Mobile|Android|Silk/i.test(navigator.userAgent)
      @.setDevice()
    else
      @.setAnchored()

  setDevice: =>

    ## Find the current device
    if /iPhone|iPad|iPod/i.test(navigator.userAgent)
      currentDevice = 'ios'
    else if /Silk/i.test(navigator.userAgent)
      currentDevice = 'kindle'
    else if /Android|Nexus/i.test(navigator.userAgent)
      currentDevice = 'android'

    if currentDevice is @_properties.targetDevice
      core.removeClass @_properties.target, 'visuallyhidden'

    else if currentDevice isnt @_properties.targetDevice
      core.addClass @_properties.target, 'visuallyhidden'

  setAnchored: =>

    # Make sure that the link is set for anchored
    if @_properties.targetDevice is 'anchored'

      console.log @_properties

      userAgentLinks = document.querySelectorAll('[data-user-agent]')

      for link in @_properties.userAgentLinks

        userAgent = link.dataset.userAgent.split(',')

        if userAgent.length > 1

          targetDevice = userAgent[1].trim()

          unless targetDevice is 'anchored'
            core.addClass link, 'visuallyhidden'

if core?
  core.addPlugin('userAgent', userAgent, '[data-user-agent]')
