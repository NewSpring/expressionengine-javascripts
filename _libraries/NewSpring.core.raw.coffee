

###

@class NewSpringUtil

@author
  James E Baxley III
  NewSpring Church

@version 0.4

###
class NewSpringUtil

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
      .mapEvents()
      # .bindLazyLoad()
      .bindSmoothScroll()







  ###

  @FUNCTIONS

  ###


  mapEvents: =>

    this
    # Clean the object
    # @.events.on('clean', @.clean )




  ###

    @important

    Plugin framework defined below


  ###

  addPlugin: (name, obj, attr, cb) =>

    # unless @_properties.pluginstest?
    #   @_properties.pluginstest = {}

    savePlugin = (name, obj, attr, cb) =>

      @['plugins'][name] =
        _id: name
        model: obj
        attr: attr
        callback: cb

    if @.plugins.length

      for plugin in @.plugins
        unless plugin._id is obj.name
          savePlugin(name, obj, attr, cb)

        @.addModel document, obj, attr, cb
        return
    else
      savePlugin(name, obj, attr, cb)


    @.addModel document, obj, attr, cb


  nameSpace: (target, attribute, obj, force) =>

    originalAttr = attribute.replace(/[\[\]']+/g,'')

    # get id for namespace
    params = target.attributes[originalAttr].value.split(',')

    # clean up whitespace
    params = params.map (param) -> param.trim()

    # set attribute name
    attribute = originalAttr.split '-'

    # add to core object
    unless @[attribute[1]]
      @[attribute[1]] = {}


    # Create new object and bind it to its nameSpace
    unless @[attribute[1]][params[0]]
      @[attribute[1]][params[0]] = new obj target, originalAttr

    if force
      @[attribute[1]][params[0]] = null
      @[attribute[1]][params[0]] = new obj target, originalAttr


  updateModels: (scope, force) =>

    for plugin in core.flattenObject @['plugins']
      @.addModel scope, plugin.model, plugin.attr, false, force


  addModel: (scope, model, attr, cb, force) =>

    for target in scope.querySelectorAll(attr)
      @.nameSpace target, attr, model, force

    if scope.querySelectorAll(attr).length
      if cb then cb()



  ###

    @important

    End plugin framework

  ###



  bindLazyLoad: ->
    if echo?
      echo.init
        offset: 100
        throttle: 250
        unload: false
      this




  bindSmoothScroll: ->

    if smoothScroll?
      smoothScroll.init(
        {
          "offset": 0
          "updateURL": false
        }
      )





  ###

  @function debounce()

  @param {Function} call back to be debounced on multifire resize

  @return new Debonce object

  ###
  debounce: (callback) =>
    debouncing = null

    debouncing ?= new Debouncer callback




  ###

  @function doesVariableExist()

  @param {Val} for query variable

  @return {Boolean} if query varible exists

  ###
  doesVariableExist: (val) ->
    query = window.location.search.substring(1)
    vars = query.split("&")

    for element of vars
      pair = vars[element].split "="
      if decodeURIComponent(pair[1]) is val
        return true

    return false




  ###

  @function doesQueryVariableExist()

  @param {Val} for query variable

  @return {Boolean} if query varible exists

  ###
  doesQueryVariableExist: (val) ->
    query = window.location.search.substring(1)
    vars = query.split("&")

    for element of vars
      pair = vars[element].split "="
      if decodeURIComponent(pair[0]) is val
        return true

    return false




  ###

  @function flatten()

  @param {Array} single or multilevel array

  @return {Array} a flattened version of an array.

  @note
    Handy for getting a list of children from the nodes.

  ###
  flatten: (array) ->
    flattened = []
    for element in array
      if element instanceof Array
        flattened = flattened.concat @.flatten element
      else
        flattened.push element
    flattened




  ###

  @function getKeys()

  @param {Object}
  @param {value}

  @return {Array} array of keys that match on a certain value

  @note
    helpful for searching objects


  @todo add ability to search string and multi level

  ###
  getKeys: (obj, val) ->
    objects = []
    for element of obj
      continue unless obj.hasOwnProperty(element)
      if obj[element] is "object"
        objects = objects.concat @.getKeys obj[element], val
      else
        objects.push element if obj[element] is val
    objects




  ###

  @function getQueryVariable()

  @param {Val}

  @return {Array} array of query values in url string matching the value

  ###
  getQueryVariable: (val) ->

    query = window.location.search.substring(1)
    vars = query.split("&")

    results = vars.filter( (element) ->
        pair = element.split "="
        if decodeURIComponent(pair[0]) is val
            return decodeURIComponent(pair[1])
    )

    return results





  ###

  @function isElementInView()

  @param {Element} element to check against

  @return {Boolean} if element is in view

  ###
  isElementInView: (element) ->
    if element instanceof jQuery then element = element.get(0)
    coords = element.getBoundingClientRect()
    (Math.abs(coords.left) >= 0 and Math.abs(coords.top)) <= (window.innerHeight or document.documentElement.clientHeight)



  ###

  @function isMobile()

  @return {Boolean} true if Mobile

  ###
  isMobile: =>
    mobile = /(Android|iPhone|iPad|iPod|IEMobile)/g.test( navigator.userAgent )





  ###

  @function last()

  @param {Array}
  @param {Val} ** optional

  @return {Val} last value of array or value certain length from end

  ###
  last: (array, back) ->
    array[array.length - (back or 0) - 1]





  ###

  @function preCacheImgs()

  @param {Array} array of img src

  @chainable

  ###
  preCacheImgs: (array) =>
    cache = (array) ->
      i = 0
      while i < array.length
        url = array[i]
        img = new Image()
        img.src = url
        i++

    cache array

    this




  ###

  @function preCacheVideos()

  @param {Array} array of video src

  @chainable

  ###
  preCacheVideos: (array) =>
    cache = (array) ->
      i = 0
      while i < array.length
        url = array[i]
        video = document.createElement 'video'
        video.src = url
        i++

    cache array

    this




  ###

  @function toggleClass()

  @param {Element} element to be toggled

  @param {String} classname to be toggled

  @chainable

  ###
  toggleClass: (element, klassName) =>

    # Make sure element and class are specififed
    return this if not element or not klassName

    # if called using jQuery then convert to element node
    if element instanceof jQuery then element = element.get(0)

    # get current class list
    klassString = element.className

    # See if target class is in current class list
    nameIndex = klassString.indexOf klassName

    # if name is not in class list, add it
    if nameIndex is -1

      # Add class to class list
      klassString += " #{klassName}"

    else
      # If class name is in string, remove it via substring manipulation
      klassString = klassString.substr(0, nameIndex) + klassString.substr(nameIndex + klassName.length)

    # updated elements class name
    element.className = klassString.trim()



    this



  hasClass: (elem, className) ->
    new RegExp(" " + className + " ").test " " + elem.className + " "



  addClass: (elem, className) =>
    elem.className += " " + className  unless @.hasClass(elem, className)

    this



  removeClass: (elem, className) =>
    newClass = " " + elem.className.replace(/[\t\r\n]/g, " ") + " "
    if @.hasClass(elem, className)
      newClass = newClass.replace(" " + className + " ", " ")  while newClass.indexOf(" " + className + " ") >= 0
      elem.className = newClass.replace(/^\s+|\s+$/g, "")

    this




  findAttr: (element, searchTerm) =>

    if element?
      attributes = @.flatten(element.attributes)

      for attr in attributes

        unless attr.name.indexOf searchTerm
          return {
            'ele': element
            'attrName': attr.name
            'attrVal': attr.value
          }

      return @.findAttr(element.parentElement, searchTerm)







  ###

  @function truthful()

  @param {Array} any array to be tested for true values

  @return {Array} array without false values

  @note
    Handy for triming out all falsy values from an array.

  ###

  truthful: (array) ->
    item for item in array when item



  flattenObject: (object) =>
    array = []
    for value of object

      array.push object[value] if object.hasOwnProperty(value)
    return array



  isElement: (o) ->

    (if typeof HTMLElement is "object" then o instanceof HTMLElement else o and typeof o is "object" and o isnt null and o.nodeType is 1 and typeof o.nodeName is "string")




window.core = new NewSpringUtil
