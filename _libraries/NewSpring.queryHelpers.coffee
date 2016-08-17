###
@class queryHelpers

@author
  Edolyne Long
  NewSpring Church

@version 0.1

@note
  This is a library for url query string helpers.
  This relies on the core js library to be present.

###
class queryHelpers

  ###

	  Constructor function runs when object gets initialized

	  @param {Ojbect} options for setting up the class

  ###

  constructor: (data) ->

    @_properties =
      data: data

    @['plugins'] = {}


    if EventEmitter? then @.events = new EventEmitter()

    @
      .scrollToList()

    # Scroll to location query string
    if core.doesQueryVariableExist "data-scroll"
      @.scrollToList()

  scrollToList: ->

    # Returns Array of Strings
    queryValue = core.getQueryVariable "data-scroll"
    # Get the first value of the array and split by the '='
    queryValue = queryValue[0].split('=')
    # Get the value after the split, and make sure there is no whitespace
    queryValue = queryValue[1].trim()

    trigger = document.querySelector('body')

    if smoothScroll
      smoothScroll.animateScroll(trigger, "##{queryValue}", {updateURL: false})
    else
      document.querySelector("##{queryValue}").scrollIntoView({block: "start", behavior: "smooth"})

window.query = new queryHelpers