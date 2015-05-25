
`
//= require ./../search/autocomplete.js
`

###
Base class for all input controlled AJAX live searches

@author
  James E Baxley III
  NewSpring Church

@version 0.1

@param {Object} options for setting up the class


@example Extending within another class
  class GoogleSearch extends AjaxSearch

@example Initiating an AJAX search
  var livesearch = new AjaxSearch sampleData


###
class AjaxSearch

  ###
  Constructor function runs when object gets initialized

  @param {Object} options for setting up the class

  ###
  constructor: (@data, attr, config) ->
    # Check and see if called by jQuery and convert to node
    if @data instanceof jQuery then @data = @data.get(0)

    # Get data from attribute
    params = @data.attributes[attr].value.split(',')

    params = params.map (param) -> param.trim()

    # [todo] - write better string to value and array method
    # solution for arrays in params object
    if params.length > 2
      meta = params.splice(0, 1)
      json = params.join(',')
      params = meta.concat json


    autocompleteData =
      try
        JSON.parse @data.attributes['data-google-search-autocomplete'].value
      catch e then null


    # bind element and properties to private @_properties variable
    @_properties = {
      _id : params[0]
      type: config._id
      params: try JSON.parse(params[1]); catch e then {}
      target: @data
      autocomplete: autocompleteData
      triggers: {}
      query: {}
      config: config
      response:
        target:
          document
            .querySelectorAll(
              '[' + attr + '-results="' + params[0] + '"]'
            )[0]
    }

    # Bind events to base
    if EventEmitter? then @.events = new EventEmitter()

    # Register triggers with local and with core
    # create array of trigger values
    triggers = ['open', 'close', 'trigger']

    for trigger in triggers

      @_properties.triggers[trigger] =
        document
          .querySelectorAll(
            '[' + attr + '-' + trigger + '="' + params[0] + '"]'
          )[0]


    # Construct object watchers
    @.mapEvents()
      .bindKeyup()
      .bindAutoComplete()
      .extend()

    # if triggers then bind them
    if @_properties.triggers.open? or @_properties.triggers.close? or @_properties.triggers.trigger?
      @.bindTriggers()


    @_properties.triggers['link'] =
      document
        .querySelectorAll(
          '[' + attr + '-link="' + params[0] + '"]'
        )

    # if search triggers found bind them
    if @_properties.triggers.link?
      @.bindAutofill()

    # start waiting for search
    @.events.emit('search-ready')



  ###

    @.clean()

    @note
      Resets all search params and states

  ###
  clean: =>

    # Empty search field
    @_properties.target.value = ''

    # Empty search params
    @_properties.query = {}

    # Reset url
    history.pushState('', '',
      window.location.origin + (window.location.pathname || ''))

    # remove searching class
    core.removeClass @_properties.target, 'searching'

    # add search class back
    core.addClass @_properties.target, 'search'

    #add hidding class to repsonse container
    core.addClass @_properties.response.target, 'searching'
    core.removeClass @_properties.response.target, 'results--returned'

    #empty response container
    response = @_properties.response.target
    while response.firstChild
      response.removeChild(response.firstChild)



  bindAutofill: =>

    for link in @_properties.triggers.link

      search = =>

        linkText = event.target.innerHTML
          .replace(/[\.,-\/#!$%\^&\*;:{}=\-_`~()]/g,"").trim()



        @.events.emit('search', linkText)

      link.addEventListener('click', search, false)



    this



  mapEvents: =>

    # Clean the object
    @.events.on('clean', @.clean )

    # Search is ready
    @.events.on('search-ready', () =>

      @_properties.target.value = @.getQueryVariable()
      @.manageClasses('search-ready')



      if @_properties.target.value.length > 3
        @.events.emit('search', @_properties.target.value)
    )


    # Autocomplete action clicked
    $(@_properties.target).bind( 'typeahead:selected', (event) =>
      @_properties.target.blur()
      # Trigger search sequence
      @.events.emit('search', event.target.value)


    )

    # Search has triggered
    @.events.on('search', (query) =>

      unless query is @_properties.query._search

        @_properties.query = {}

      @.storeQueryTerm query


      @_properties.target.blur()

      @_properties.target.value = query

      body = document.getElementsByTagName('BODY')[0]

      if query is 'do a barrel roll'
        core.addClass(body, 'roll')
      else
        core.removeClass(body, 'roll')


      # Trigger async build of URL string
      @.events.emit('query-changed')

      @.search()
    )

    # Query has changed
    @.events.on('query-changed', @.updateUrl )


    # Search has triggered
    @.events.on('searching', () =>
      @.manageClasses('searching')

    )

    # Search has triggered
    @.events.on('result', (result) =>
      @.validate result
    )

    @.events.on('results-prep', (result) =>
      @.prepResults result

    )

    @.events.on('results-ready', (result) =>
      @.showPage result
    )

    # Search results have rendered
    @.events.on('results-rendered', (result) =>
      @.manageClasses('results--returned')
    )

    this



  manageClasses: (action) =>
      containers = [
        @_properties.target
        @_properties.triggers.open
        @_properties.triggers.close
        @_properties.response.target
      ]

      containers = containers.filter(core.isElement)

      switch action
        when 'search-ready'
          core.addClass(element, action) for element in containers
        when 'searching'
          core.removeClass(element, 'search-ready') for element in containers
          core.addClass(element, action) for element in containers
        when 'results--returned'
          core.addClass(element, 'search-ready') for element in containers
          core.removeClass(element, 'searching') for element in containers
          core.addClass(element, action) for element in containers


    this



  storeQueryTerm: (query) =>

    @_properties.query._search = query

    this



  getQueryVariable: =>
    query = window.location.search.substring(1)
    vars = query.split("?")[0].split("&")
    if window.location.hash.split('#')[1] is @_properties._id

      for term in vars
        key = term.split("=")[0]
        if key is "search"
          queryTerm = decodeURIComponent(term.split("=")[1])
          @.storeQueryTerm queryTerm
        else
          if key and term
            @_properties.query[key] = term

      @.events.emit('open')

    unless queryTerm?
      queryTerm = ''

    return queryTerm




  bindKeyup: =>

    @_properties.target.addEventListener( 'keyup', (event) =>
      input = @_properties.target

      # Not searching
      if input.value.length is 0 then @.events.emit('clean')

      # clearTimeout buildDelay
      # buildDelay = setTimeout =>
      #   if input.value.length > 3
      #
      #     # Trigger search sequence
      #     @.events.emit('search', input.value)
      #
      #
      # , @_properties.params.delay || 750

      if event.keyCode is 13
        @.events.emit('search', input.value)

    , false)

    this



  bindTriggers: =>

    @.events.on('open', () =>

      unless core.hasClass @_properties.target, 'active'
        @_properties.target.focus()

      core.toggleClass @_properties.target, 'active'

      # [todo] -- right better event biding for exterior events on load
      setTimeout =>
        @.events.emit('extend-open')
      , 0



    )

    @.events.on('close', () =>
      core.toggleClass @_properties.target, 'active'
      setTimeout =>
        @.events.emit('extend-close')
      , 0
      @.events.emit('clean')

    )

    if @_properties.triggers.open? and core.isElement @_properties.triggers.open
      open = () =>

        @.events.emit('open')

      @_properties.triggers.open
        .addEventListener('click', open, false)

    if @_properties.triggers.close? and
      core.isElement @_properties.triggers.close

        close = () =>

          @.events.emit('close')

        @_properties.triggers.close
          .addEventListener('click', close, false)


    if @_properties.triggers.trigger? and
        core.isElement @_properties.triggers.trigger

          search = (e) =>
            @.events.emit('search', @_properties.target.value)

          @_properties.triggers.trigger
            .addEventListener('click', search, false)






  bindAutoComplete: =>
    if @_properties.autocomplete?
      if Bloodhound?

        setUpBloodhound = (nameSpace) =>
          bloodhoundObj = nameSpace[0]

          return bloodhoundObj = new Bloodhound({
            datumTokenizer: (d) ->

              return Bloodhound.tokenizers.whitespace(d[nameSpace[1]])

            queryTokenizer: Bloodhound.tokenizers.whitespace

            prefetch: nameSpace[3]
          })



        dataSets = []

        for element in @_properties.autocomplete

          nameSpace = []
          for key of element
            name = key
            value = element[key]
            nameSpace.push name, value

          bloodhoundObj = setUpBloodhound nameSpace

          bloodhoundObj.initialize()

          templateName = nameSpace[0]
          template = Handlebars.getTemplate( ('search_'+ templateName ), true)

          autocomplete =
            name: nameSpace[0]
            displayKey: nameSpace[1]
            source: bloodhoundObj.ttAdapter()
            templates:
              suggestion: template

          dataSets.push autocomplete


        $(@_properties.target).typeahead({
          highlight: true
          hint: false
        }, dataSets)

    this



  updateUrl:  =>

    queries = core.flattenObject @_properties.query

    if queries.length > 1
      urlString = '?search=' + queries.join('&') + '#' + @_properties._id
    else
      urlString = '?search=' + queries[0] + '#' + @_properties._id


    if window.history?
      history.pushState('', '', urlString)



  search: =>

    url = core.flattenObject @_properties.config[@_properties.type]

    queries = core.flattenObject @_properties.query

    if queries.length > 1

      encodedQueries = []
      for query in queries
        if query.indexOf('=') > 0
          arr = query.split('=')
          query = arr[0] + "=" + encodeURIComponent(arr[1])
        else
          query = encodeURIComponent(query)

        encodedQueries.push(query)
      queries = encodedQueries.join('&')


    else
      queries = encodeURIComponent(queries[0])


    url = url.join('&') + '&q=' + queries

    ajax = new XMLHttpRequest()
    ajax.onreadystatechange = =>
      return  if ajax.readyState isnt 4 or ajax.status isnt 200
      @.events.emit 'result', JSON.parse(ajax.response)
    ajax.open "GET", url, true
    ajax.send()
    @.events.emit 'searching'



  validate: (result) =>

    # Check against previous result
    result = result unless JSON.stringify(result) is JSON.stringify(@_properties.response.data)

    # Reset data from search
    @_properties.response.data = result

    @.events.emit('results-prep', result)



  prepResults: (results) =>

    @.events.emit('results-ready', results)



  showPage: (result) =>

    template = @_properties.params.template || 'google_results'

    compiledTemplate = Handlebars.getTemplate template

    @_properties.response.target.innerHTML = compiledTemplate result

    @.events.emit('results-rendered', result)



  extend: =>
    this
    # Easy way for object extenders to gain a constructor



class GoogleSearch extends AjaxSearch

  constructor: (@data, attr) ->
    config =
      _id: 'google'
      google:
        baseUrl: "/?ACT=191"
    super @data, attr, config

  getName: ->
    return 'GoogleSearch'

  extend: =>
    @.events.on('results-rendered', (result) =>
      @.bindPagination result
      @.events.emit 'query-changed'
    )

    this



  bindPagination: (result) =>

    bindPrevious = =>
      target = @_properties.response.target.querySelectorAll('[data-search-previous]')[0]
      if target?
        target.onclick = (e) =>

          @_properties.query.start = "start="+result[0].pagination.previousPage[0].startIndex

          @.events.emit 'search', @_properties.query._search
      this

    if result[0].pagination.previousPage then bindPrevious()



    bindNext = =>
      target = @_properties.response.target.querySelectorAll('[data-search-next]')[0]

      if target?
        target.onclick = (e) =>

          @_properties.query.start = "start="+result[0].pagination.nextPage[0].startIndex

          @.events.emit 'search', @_properties.query._search

      this

    if result[0].pagination.nextPage then bindNext()



if core?
  core.addPlugin('GoogleSearch', GoogleSearch, '[data-google-search]')
