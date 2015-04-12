###
@class Panel

@author
  James E Baxley III
  NewSpring Church

@version 0.1

@note
  Handles interactions of panels based on data- parameters

###
class Panel
  constructor: (@data, attr) ->

    # Get data from attribute
    params = @data.attributes[attr].value.split(',')
    params = params.map (param) -> param.trim()


    # Define properties
    @_properties =
      attr: attr
      _id: params[0]
      target : @data
      panels: {}
      triggers: {}


    @.findPanels()
    @.findTriggers()

    if EventEmitter? then @.events = new EventEmitter()


    @.bindEvents()


  findPanels: =>
    panels = document.querySelectorAll('[data-panel]')

    for panel in panels
      if panel.dataset.panel.split(',')[0] is @_properties._id
        id = panel.dataset.panel.split(',')[1].trim()
        @_properties.panels[id] = panel



  findTriggers: =>

    # Find all the triggers
    triggers = document.querySelectorAll('[data-panel-show]')

    for trigger in triggers

      _id = trigger.dataset.panelShow.split(',')[0].trim()
      triggerId = trigger.dataset.panelShow.split(',')[2].trim()

      # Make sure its in the right group
      if _id is @_properties._id
        params = trigger.dataset.panelShow.split(',')
        if params[3]
          force = try JSON.parse(params[3]); catch e then false
        # If it hasn't been found, bind the click event
        if @_properties.triggers[triggerId] is `undefined` or force
          @_properties.triggers[triggerId] = trigger

          @.bindClick( trigger )



  bindClick: (trigger) =>

    trigger.onclick = (e) =>
      e.preventDefault()

      params = trigger.dataset.panelShow.split(',')
      url = params[1].trim()

      if params[3]?
        force = try JSON.parse(params[3]); catch e then false


      @.loadPanel url, force


  ajaxPanel: (panel) =>

    ajax = new XMLHttpRequest()
    ajax.onreadystatechange = =>


      return if ajax.readyState isnt 4 or ajax.status isnt 200

      content = ajax.response.body.querySelectorAll('[data-panel]')[0]

      content.style.display = "none"
      @_properties.target.appendChild(content)
      @.events.emit('loaded', content)


    ajax.open "GET", panel, true
    ajax.responseType = 'document'
    ajax.send()




  loadPanel: (panel, force) =>

    if force is true

      @_properties.force = true
      @.ajaxPanel(panel, force)
      if core['panel'][@_properties._id]._properties.panels[panel]?
        @_properties.panels[panel]
          .parentNode.removeChild(@_properties.panels[panel])

      return false

    # lets make sure panel has no whitespace
    panel = panel.trim()

    # First things first check the plugins
    unless core['panel'][@_properties._id]._properties.panels[panel] is `undefined`

      # We found one! Show toggle panels to show it
      @.hidePanels()

      @.showPanel(core['panel'][@_properties._id]._properties.panels[panel])





    else

      # First search the DOM
      panels = document
        .querySelectorAll('[data-panel]')

      # Find all the panels and log them
      for existingPanel in panels

        if existingPanel.dataset.panel.split(',')[1] is panel

          # We found one! Show toggle panels to show it
          @.hidePanels()
          @.showPanel(existingPanel)
        else
          compiledTemplate = Handlebars.getTemplate panel

          if typeof compiledTemplate is 'function'

            # We found a handlebar template, lets show it
            content = compiledTemplate()

            @.events.emit('loaded', content)

          else

            # No luck finding in the DOM or handlebars, time to ajax
            @.ajaxPanel(panel);

            # End loop
            return false



  showPanel: (panel) =>

    panel.style.display = "block"
    core.addClass panel, "panel--active"

    panelTrigger = document.querySelectorAll("[data-panel-show*=\"#{panel.dataset.panel}\"]")

    for currentTrigger in panelTrigger
      core.addClass currentTrigger, 'panel--active--link'


  hidePanel: (panel) =>

    if document.getElementsByClassName("panel--active--link")
      previousActivePanels = document.getElementsByClassName("panel--active--link")

      for previousPanel in previousActivePanels
        core.removeClass previousPanel, "panel--active--link"

    panel.style.display = "none"
    core.removeClass panel, "panel--active"

    this



  hidePanels: =>

    for panel in core.flattenObject(core['panel'][@_properties._id]._properties.panels)

      @.hidePanel(panel)

    this



  bindEvents: =>

    @.events.on('loaded', (content) =>

      # Delete current panels
      if @_properties.force
        for panel in @_properties.panels
          panel.parentNode.removeChild(panel)
        # @_properties.pan

      # Update core for triggerable markup
      core.updateModels content, @_properties.force

      # Search for new triggers
      @.findTriggers(@_properties.force)

      # Search for new panels
      @.findPanels()

      # Hide all other panels
      @.hidePanels()

      # Show this one
      @.showPanel(content)
    )

    this






if core?
  core.addPlugin('Panel', Panel, '[data-panel-group]')
