###
@class Accordion

@author
  James E Baxley III
  NewSpring Church

@version 0.1

@note
  Handles interactions of accordions based on data- parameters

###
class Accordion
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
      type : params[1]
    }

    if EventEmitter? then @.events = new EventEmitter()

    # Bind click envents to accordion behaviors
    @.bindClicks()


  bindClicks: =>

    # Find triggers within accordion
    triggers = @_properties.target.querySelectorAll('[data-accordion-trigger]')

    # Add triggers to properties
    @_properties.triggers = triggers

    # Make all the triggers do the thing
    for trigger in triggers

      trigger.addEventListener 'click', @.expandBellow, false


  expandBellow: (event) =>

    event.preventDefault()
    klassName = 'expanded'
    bellow = @.findClosestBellow event.target

    # Toggle the bellow open or closed
    core.toggleClass bellow, klassName

    # If not a multi, close the other bellows
    if @_properties.type isnt 'multi'

      for trigger in @_properties.triggers

        otherBellow = @.findClosestBellow trigger

        # Closing the bellow just opened would be counterproductive
        core.removeClass otherBellow, klassName unless otherBellow is bellow

    @.events.emit('toggled', event)

    # Allow chaining methods
    return this


  findClosestBellow: (trigger) ->

    klass = 'accordion__item'
    currentNode = trigger

    # Traverse up the DOM until we find the bellow (class "accordion__item")
    while not core.hasClass currentNode, klass

      currentNode = currentNode.parentNode

    return currentNode


if core?
  core.addPlugin('Accordion', Accordion, '[data-accordion]')
