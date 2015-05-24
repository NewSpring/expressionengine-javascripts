

###
@class AjaxForm

@author
  James E Baxley III
  NewSpring Church

@version 0.1

@note
  Handles interactions of forms based on data- parameters

###
class AjaxForm
  constructor: (@data, attr) ->

    # Get data from attribute
    params = @data.attributes[attr].value.split(',')
    params = params.map (param) -> param.trim()

    # [todo] - write better string to value and array method
    # solution for arrays in params object
    if params.length > 2
      meta = params.splice(0, 2)
      json = params.join(',')
      params = meta.concat json

    linked = false

    # Get linked form if needed
    unless @data.attributes[attr + '-link'] is `undefined`
      id = @data.attributes[attr + '-link'].value
      linked = document.querySelectorAll('[' + attr + '-link="' + id + '"]')[0]
      linked = linked.form


    # Define properties
    @_properties =
      attr: attr
      _id: params[0]
      target : @data.form
      linked: linked
      response: try JSON.parse(params[2]); catch e then undefined
      auto: try JSON.parse(params[1]); catch e then false
      triggers: {}


    # Register triggers with local and with core
    # create array of trigger values
    triggers = ['error']

    for trigger in triggers
      @_properties.triggers[trigger] =
        document
          .querySelectorAll(
            '[' + attr + '-' + trigger + '*="' + params[0] + '"]'
          )


    if EventEmitter? then @.events = new EventEmitter()

    @.bindAjax()

    # if there is a linked form then bind values
    if @_properties.linked
      @.bindForms()




  bindForms: =>


    linked = @.getFields @_properties.linked
    original = @.getFields @_properties.target

    @_properties.linkedFields = @.filterFields( original, linked)


  filterFields: (array1, array2) ->

    # least intensive method I can think of right now.
    # I'm sure there is a better way to do this right?
    matching = array1.filter( (input) ->
      for link in array2
        if (
          link.name.indexOf(input.name) > -1 or
          input.name.indexOf(link.name) > -1 and
          input.name.length > 0 and
          link.name.length > 0
          )
          link.dataset.link = link.name
          input.dataset.link = link.name
          return true
    )

    return matching


  getFields: (form) ->

    # This seems like a really ugly way to do this
    # Not sure why array.concat(array1, array2) isn't working
    inputs = form.getElementsByTagName('INPUT')
    selects = form.getElementsByTagName('SELECT')

    fields = []

    for input in inputs
      fields.push input

    for select in selects
      fields.push select

    return fields


  matchFields: =>

    sync = (input) ->
      value = input.value

      linked = document
        .querySelectorAll('[data-link="' + input.dataset.link + '"]')[0]

      unless linked.type is 'hidden'
        linked.value = value

    sync input for input in @_properties.linkedFields


  bindAjax: =>

    plugin = @

    $(@_properties.target).ajaxForm
      dataType: "json"
      beforeSubmit: (arr, $form, options) ->


        unless plugin._properties.processing

          if plugin._properties.linked

            submitBtn = plugin._properties.target
              .querySelectorAll('[name="submit"]')[0]

            plugin._properties.processing = true
            submitBtn.dataset.originalText = submitBtn.value
            core.addClass submitBtn, 'btn--icon'
            submitBtn.value = 'Purchasing...'

            plugin.matchFields()

            if core.mappedFields isnt `undefined`

              form = plugin._properties.target

              for field of core.mappedFields
                mappedField = form.querySelectorAll('[name="' + field + '"]')

                for mapped in mappedField
                  mapped.value = core.mappedFields[field]


            $(plugin._properties.linked).ajaxSubmit()


        else return false


      success: (data) ->

        submitBtn = plugin._properties.target
          .querySelectorAll('[name="submit"]')[0]

        if submitBtn?

          plugin._properties.processing = false
          core.removeClass submitBtn, 'btn--icon'
          submitBtn.value = submitBtn.dataset.originalText


        if data.success

          if document.querySelectorAll('.panel--active .form--error')
            plugin.cleanErrors()

          if document.querySelector('.panel--active .form--success')
            plugin.successMessage()

          unless plugin._properties.auto
            if plugin._properties.response isnt `undefined`

              core['panel'][plugin._properties.response['panel-group']]
                .loadPanel(plugin._properties.response['panel'], true)

            else location.reload(false)

          if document.querySelectorAll('.panel--active [data-ajaxForm-success]')[0]
            plugin.successRedirect()

        else
          plugin.cleanErrors()

          if data.XID?
            plugin.updateCartForm data

          if data.errors
            plugin.returnErrors data.errors

          if data.field_errors
            plugin.returnErrors data.field_errors

      failure: (data) ->
        console.log data, 'failure'

        return

    if @_properties.auto
      submit = =>
          $( @_properties.target).submit()
      # Quick and dirty way to make sure other
      # scripts have finished before submitting
      delay = setTimeout submit, 10




  updateCartForm: (data) =>

    @_properties.target.querySelectorAll('input[name=XID]').value = data.XID

  successRedirect: =>

    panelRedirect = document.querySelectorAll('.panel--active [data-ajaxForm-success]')[0]
    panelRedirectURL = panelRedirect.getAttribute('data-ajaxForm-success')
    window.location.href = panelRedirectURL

  successMessage: =>

    successSection = document.querySelector('.panel--active .form--success')
    core.removeClass successSection, 'visuallyhidden'

  cleanErrors: =>

    for errorContainer in @_properties.triggers.error
      errors = errorContainer.querySelectorAll('.form--error')
      for error in errors

        if errorContainer.getElementsByClassName('form--label')[0]

          errorToClear = errorContainer.getElementsByClassName('form--label')[0]
          core.removeClass errorToClear, 'visuallyhidden'

        core.removeClass errorContainer, 'error'
        error.parentNode.removeChild error

  returnErrors: (error) =>
    createMessage = (message, container) =>
      errorMessage = document.createElement 'span'
      core.addClass errorMessage, 'form--error'
      errorMessage.innerText = message

      inputs = container.getElementsByTagName "INPUT"

      for input in inputs
        input.addEventListener 'focus', @.cleanErrors

      container.appendChild errorMessage
      core.addClass container, 'error'

      if container.getElementsByClassName('form--label')[0]
        label = container.getElementsByClassName('form--label')[0]
        core.addClass label, 'visuallyhidden'

    console.log @_properties
    for errorContainer in @_properties.triggers.error
      errorType = errorContainer.attributes[@_properties.attr + '-error']
        .value.split(',')[1].trim()


      # Is an array so send to default
      # if error.length
      #  message = error.join(' and ')

      #  createMessage message, errorContainer

      # Coordinates with input value
      if error[errorType]?
        createMessage error[errorType], errorContainer
        return

      # who knows what
      else if errorType is 'default'
        message = core.flattenObject( error).join(' and ')

        createMessage message, errorContainer





if core?
  core.addPlugin('AjaxForm', AjaxForm, '[data-ajaxForm]')
