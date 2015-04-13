//= include ../players/audio.min.js

###
@class Audio

@author
  James E Baxley III
  NewSpring Church

@version 0.1

@note
  Handles interactions of audio players based on data- parameters

###
class Audio
  constructor: (@data, attr) ->

    # Get data from attribute
    params = @data.attributes[attr].value.split(",")

    params = params.map (param) -> param.trim()
    # [todo] - write better string to value and array method
    # solution for arrays in params object
    if params.length > 3
      meta = params.splice(0, 2)
      json = params.join(",")
      params = meta.concat json

    # Define properties
    @_properties =
      _id: params[0]
      target: @data
      audio: params[1]
      preload: params[2]


    if EventEmitter? then @.events = new EventEmitter()

    @
      .createPlayer(@_properties.audio, @_properties.preload)
      .bindPlayer()


  createPlayer: (audioFile, preload) =>

    audio = document.createElement "audio"

    audio.src = audioFile

    audio.preload = 'none'

    @_properties.target.parentNode.insertBefore(
      audio, @_properties.target
    )

    @_properties.target.parentNode.removeChild(
      @_properties.target
    )

    @_properties.target = audio

    this


  bindPlayer: =>

    settings =
      swfLocation: "//s3.amazonaws.com.ns.assets/javascript-dependencies/audiojs.swf"
      imageLocation: "//s3.amazonaws.com/ns.assets/javascript-dependencies/player-graphics.gif"

    if audiojs
      player = audiojs.create @_properties.target, settings

      @_properties.player = player


  skipTo: (percent) =>

    @_properties.player.skipTo percent




if core?
  core.addPlugin("Audio", Audio, "[data-audio]")
