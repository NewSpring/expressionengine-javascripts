###

  @class Debouncer

  @author
    James E Baxley III
    NewSpring Church

  @version 0.3

  @note
    Handles debouncing of events via requestAnimationFrame
    @see http://www.html5rocks.com/en/tutorials/speed/animations/

###
class Debouncer
  constructor: (@data) ->

    window.requestAnimationFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame;

    @.callback = @data
    @.ticking = false

  update: =>
    @.callback and @.callback()
    @.ticking = false

  requestTick: =>
    unless @.ticking
      requestAnimationFrame(this.rafCallback || (this.rafCallback = this.update.bind(this)))
      @.ticking = true

  handleEvent: =>
    @.requestTick()

window.Debouncer = Debouncer
