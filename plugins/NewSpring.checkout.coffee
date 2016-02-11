###
@class Checkout

@author
  James E Baxley III
  NewSpring Church

@version 0.1

@note
  Handles interactions of checkouts with Cartthrob based on data- parameters

###
class Checkout

  constructor: (@data, attr) ->


    # Get data from attribute
    params = @data.attributes[attr].value.split(',')
    params = params.map (param) -> param.trim()

    # Define properties
    @_properties =
      attr: attr
      # _id: params[0]
      _id: @data.href
      entry_id: params[1]
      modal: params[2]
      target : @data
      triggers: {}
      mappedFields: try JSON.parse(@data.dataset.checkoutInfo); catch e then false
      form: document.getElementById params[1]
      instant: if (params[3]) is 'download' or 'eventInstant' then true else false
      refresh: if (params[3]) is 'eventInstant' then true else false


    if EventEmitter? then @.events = new EventEmitter()


    @
      .bindClick()
      .bindEvents()
      # .bindAjax()


  addLoading: (text) =>
    @_properties.originalText = @_properties.target.innerText
    @_properties.target.innerHTML = "#{text}...<span class='icon icon--loading'></span>"
    core.addClass @_properties.target, 'btn--icon'
      
  bindClick: =>

    checkout = (e) =>

      unless @_properties.instant
        @.addLoading("Loading")

      if @_properties.instant

        a = document.createElement("a")
        if typeof a.download is "undefined" and @_properties.refresh is false 
          e.preventDefault()
          window.open(@_properties._id, '_blank')
          console.log 'this'
        if @_properties.refresh
          @.addLoading("Processing")
          
      else
        e.preventDefa2ult()

      @.clearCart()

      return

    @_properties.target.addEventListener('click', checkout, false)

    this


  bindEvents: =>
    @.events.on('cleared', () =>

      @.submitForm()

    )

    @.events.on('added', (data) =>

      if @_properties.instant
        @.processInstant()
        @.loadModal(true)
        
        if @_properties.refresh
          setTimeout (->
            window.location.reload(true)
            return
          ), 500
        
      else
        @.loadModal()
    )


  processInstant: =>
  
    @.cleanInstant()


  cleanInstant: =>

    # find all other registered checkouts on this page
    for item in core.flattenObject core['checkout']
      unless item._properties._id is @_properties._id
        delete core['checkout'][item._properties._id]
      

  submitForm: =>

    plugin = @


    $(@_properties.form).ajaxForm
      dataType: "json"
      success: (data) ->
        if data.success
          plugin.events.emit('added', data)
        else

        return

    if typeof @_properties.form.submit is "function"
      @_properties.form.submit()
    else
      @_properties.form.submit.click()



  loadModal: ( hidden ) =>

    # First things first, lets destroy existing modal
    existingModal = document
      .querySelectorAll('[data-modal="' + @_properties.modal + '"]')[0]

    if existingModal then existingModal.parentNode.removeChild(existingModal)

    Modal = core['plugins']['Modal']

    modalName = if (modal?) then modal else @_properties.modal


    if Modal?
      if core.modal?
        core.modal[modalName] = undefined
        tmpl = modalName
        core.modal[tmpl] = new Modal.model tmpl, 'data-modal-open', "preload"

      else
        core.modal = {}
        tmpl = modalName
        core.modal[tmpl] = new Modal.model tmpl, 'data-modal-open', "preload"



    unless hidden
      core.modal[modalName].toggleModal()


    @.mapFields()


    removeLoading =  =>
      @_properties.target.innerHTML = ''
      @_properties.target.innerText = @_properties.originalText
      @_properties.target.originalText = ''
      core.removeClass @_properties.target, 'btn--icon'

    unless @_properties.instant or @_properties.refresh
      delay = setTimeout removeLoading, 5000
      
    this

  mapFields: =>

    if @_properties.mappedFields
      # I hate doing this
      core.mappedFields = @_properties.mappedFields
      form = core.modal[@_properties.modal]._properties.modal

      for field of @_properties.mappedFields
        mappedField = form.querySelectorAll('[name="' + field + '"]')

        for mapped in mappedField
          mapped.value = @_properties.mappedFields[field]

    this

  clearCart: =>

    request = new XMLHttpRequest()
    request.open "GET", "/checkout/clearcart", true

    request.onload = =>
      if request.status >= 200 and request.status < 400

        @.events.emit('cleared')
      return


    # We reached our target server, but it returned an error
    request.onerror = ->
      console.log 'error has occured'


    # There was a connection error of some sort
    request.send()




if core?
  core.addPlugin('Checkout', Checkout, '[data-checkout]')
