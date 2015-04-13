###
@class Modal

@author
  James E Baxley III
  NewSpring Church

@version 0.1

@note

###

class Modal

  constructor: (@data, attr, toggle) ->

    if @data instanceof jQuery then @data = @data.get(0)

    if typeof @data isnt 'string'
      # Get data from attribute
      params = @data.attributes[attr].value.split(',')

      params = params.map (param) -> param.trim()

      id = params[0]
    else
      id = @data


    @_properties =
      _id : id
      triggers: document.querySelectorAll( '[' + attr + '*="' + id + '"]' )
      class: if params? then params[1]
      preload: if params? then params[2]


    if EventEmitter? then @.events = new EventEmitter()

    if @_properties.preload or toggle is "preload"

      @.getModal()


    if typeof @data isnt 'string'
      @.bindOpen()




  getModal: (show) =>
    modal = document.querySelectorAll('[data-modal="' + @_properties._id + '"]')[0]


    unless modal
      @_properties.inDOM = false

      compiledTemplate = Handlebars.getTemplate(@_properties._id)

      modal = document.createElement 'div'

      if @_properties.class?
        core.addClass modal, @_properties.class

      core.addClass modal, 'modal'

      modal.setAttribute('data-modal', @_properties._id)

      data = {}

      if @_properties.triggers[0]?
        if @_properties.triggers[0].attributes['data-modal-content']
          data = JSON.parse(
            @_properties.triggers[0].attributes['data-modal-content'].value
          )


      if typeof compiledTemplate is 'function'
        modal.innerHTML = compiledTemplate(data)
        @.createModal modal
      else
        ajax = new XMLHttpRequest()
        ajax.onreadystatechange = =>

          return if ajax.readyState isnt 4 or ajax.status isnt 200
          modal.innerHTML = ajax.response
          @.createModal modal, show


        ajax.open "GET", @_properties._id, false
        ajax.send()



    else
        @_properties.inDOM = true
        unless @_properties.modal?
            @_properties.modal = modal
            @.bindClose()

    this



  toggleClasses: (modal) ->

    core.toggleClass modal, "modal--active"

    html = document.getElementsByTagName("html")[0]
    core.toggleClass html, "modal--opened"

    panel = document.querySelectorAll('[data-panel]')[0]
    core.toggleClass panel, "panel--active"


  createModal: (modal, show) =>


    @_properties.modal = modal
    @.bindClose()

    unless @_properties.inDOM
      document.getElementsByTagName('body')[0].appendChild(@_properties.modal)

      core.updateModels @_properties.modal


      @.events.emit('added', @_properties.modal)

      @_properties.inDOM = true

      if show then @.toggleModal()



  toggleModal: =>


    if @_properties.modal is `undefined`
      @.getModal(true)
    else
      @.toggleClasses @_properties.modal

      unless core.hasClass( @_properties.modal, 'modal--active')
        @.events.emit('close', @_properties.modal)

      else
        @.events.emit('open', @_properties.modal)

    this



  bindOpen: =>

    for trigger in @_properties.triggers

      click = (e) =>
        e.preventDefault()
        unless @_properties.modal?
          @.getModal()
        @.toggleModal()

      trigger.addEventListener('click', click, false)

    this



  bindClose: =>

    @.closeBtns = @_properties.modal
      .querySelectorAll('[data-modal-close="' + @_properties._id + '"]')

    if @.closeBtns
      for btn in @.closeBtns
        btn.addEventListener("click", @.toggleModal, false)

    this

if core?
  core.addPlugin('Modal', Modal, '[data-modal-open]')

#On Page Load Modals

#Check for attribute
if document.querySelectorAll('[data-modal-open-onload]')[0]

  #Find the attribute
  onloadModal = document.querySelectorAll('[data-modal-open-onload]')[0]

  #Hide it via class
  core.addClass onloadModal, 'visuallyhidden'

  #Get the url data
  onloadModalUrl = onloadModal.getAttribute('data-modal-open-onload')

  #Open it up, up, up
  core.modal[onloadModalUrl].toggleModal()
