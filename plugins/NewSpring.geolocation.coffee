###
@class Googleapis, Geolocation

@author
  James E Baxley III
  Edolyne Long
  NewSpring Church

@version 0.1

@note
  Googleapis required to initialize Google maps
  Geolocation renders map view of data parameters

###

class Googleapis

  constructor: (@data) ->

    @_properties =
      scripts:
        googleapis: "https://maps.googleapis.com/maps/api/js?v=3.exp" +
          "&callback=googleapis.initialize"
      img: "//s3.amazonaws.com/ns.images/newspring/locations/newspring.mapmarker.png"
      maps: []
      styles:
        # single:
        multi: [
            {
              featureType: "road"
              elementType: "geometry"
              stylers: [{visibility: "on"}, {lightness: 70}]
            }
            {
              featureType: "poi"
              elementType: "geometry"
              stylers: [visibility: "off"]
            }
            {
              featureType: "landscape"
              elementType: "geometry"
              stylers: [color: "#fffffa"]
            }
            {
              featureType: "water"
              stylers: [lightness: 0]
            }
            {
              featureType: "road"
              elementType: "labels"
              stylers: [visibility: "on"]
            }
            {
              featureType: "transit"
              stylers: [visibility: "off"]
            }
            {
              featureType: "administrative"
              elementType: "geometry"
              stylers: [lightness: 0]
            }
          ]
        network: [
              {
                  featureType: "water"
                  elementType: "geometry"
                  stylers: [
                      {
                          color: "#a2daf2"
                      }
                  ]
              },
              {
                  featureType: "landscape.man_made"
                  elementType: "geometry"
                  stylers: [
                      {
                          color: "#f7f1df"
                      }
                  ]
              },
              {
                  featureType: "landscape.natural"
                  elementType: "geometry"
                  stylers: [
                      {
                          color: "#f7f1df"
                      }
                  ]
              },
              {
                  featureType: "landscape.natural.terrain"
                  elementType: "geometry",
                  stylers: [
                      {
                          visibility: "off"
                      }
                  ]
              },
              {
                  featureType: "poi.park"
                  elementType: "geometry"
                  stylers: [
                      {
                          color: "#f7f1df"
                      }
                  ]
              },
              {
                  featureType: "poi"
                  elementType: "labels"
                  stylers: [
                      {
                          visibility: "off"
                      }
                  ]
              },
              {
                  featureType: "poi.medical"
                  elementType: "geometry"
                  stylers: [
                      {
                          color: "#fbd3da"
                      }
                  ]
              },
              {
                  featureType: "poi.business"
                  stylers: [
                      {
                          visibility: "off"
                      }
                  ]
              },
              {
                  featureType: "road"
                  elementType: "geometry.stroke"
                  stylers: [
                      {
                          visibility: "off"
                      }
                  ]
              },
              {
                  featureType: "road.highway"
                  elementType: "geometry.fill"
                  stylers: [
                      {
                          color: "#ffe15f"
                      }
                  ]
              },
              {
                  featureType: "road.highway"
                  elementType: "geometry.stroke"
                  stylers: [
                      {
                          color: "#efd151"
                      }
                  ]
              },
              {
                  featureType: "road.arterial"
                  elementType: "geometry.fill"
                  stylers: [
                      {
                          color: "#ffffff"
                      }
                  ]
              },
              {
                  featureType: "road.local"
                  elementType: "geometry.fill"
                  stylers: [
                      {
                          color: "black"
                      }
                  ]
              },
              {
                  featureType: "transit.station.airport"
                  elementType: "geometry.fill"
                  stylers: [
                      {
                          color: "#cfb2db"
                      }
                  ]
              }
          ]



    @.loadScript()



  initialize: () =>

    @.getMarkers()


  getMarkers: () =>

    for location in core.flattenObject core.geolocation
      map = location.createMap()
      @_properties.maps.push map

  loadScript: () ->

    # Create script
    script = document.createElement "script"

    # Set src
    script.src = @_properties.scripts['googleapis']


    # Get all scripts to check against
    scripts = core.flatten document.getElementsByTagName "script"

    # Filter script to find previously loaded script
    scrpt = scripts.filter( (attr) =>
      if attr.attributes["src"]? and attr.attributes["src"].value?
        return attr.attributes["src"].value is @_properties.scripts['googleapis']
    )

    # Load script onto page unless it is already in DOM
    unless scrpt.length > 0 then document.head.appendChild script

    this



class Geolocation

  ###
  Constructor function runs when object gets initialized

  @param {Object} options for setting up the class

  ###
  constructor: (@data, attr) ->
    # Check and see if called by jQuery and convert to node
    if @data instanceof jQuery then @data = @data.get(0)

    # Get data from attribute
    params = @data.attributes[attr].value
      # .split(',')
      .split(/[,](?=[^\]]*?(?:\[))/g)


    if params.length > 2
      meta = params.splice(0, 2)
      json = params.join(',')
      params = meta.concat json

    params = params.map (param) -> param.trim()


    choosenLocations = params[1].replace(/[\[\]']+/g,'').split(',')
    choosenLocations = choosenLocations.map (param) -> param.trim()



    if typeof choosenLocations is 'string'
      choosenLocations = [choosenLocations]

    locations = try JSON.parse(params[2]); catch e

    unless choosenLocations[0] is 'all'
      locations = locations.filter( (location) =>
        for campus in choosenLocations
          if location._id
            .toLowerCase()
            .replace(' ', '')
            .indexOf(
              campus
                .toLowerCase()
                .replace(' ', '')
            ) > -1
            return true
          else false
      )


    # bind element and properties to private @_properties variable
    @_properties = {
      _id : params[0]
      target: @data
      location: choosenLocations
      locations: locations
      map: {}
      markers: []
      mapOptions: {}
      multi: false
      attr: attr
    }


    if @_properties.location[0] is 'all' or @_properties.location.length > 1
      @_properties.multi = true


    if EventEmitter? then @.events = new EventEmitter()

    @.bindEvents()

  getName: ->
    return 'Geolocation'

  bindEvents: () =>

    @.events.on('campus-found', (campus) =>

      for trigger in @_properties.findLocation
        core.removeClass trigger, 'btn--icon btn--filled'
        trigger.innerHTML = trigger.dataset.originalText

      for marker in @_properties.markers
        if marker.url is campus.url
          marker.infoWindow.open(@_properties.map, marker)

      # window.location.href = campus.url
    )

    @.events.on('finding-closest', () =>

      for trigger in @_properties.findLocation
        trigger.dataset.originalText = trigger.innerText
        trigger.innerHTML = 'Loading...<span class="icon icon--loading"></span>'
        core.addClass trigger, 'btn--icon btn--filled'

      # Modal = core.plugins.Modal
      #
      # if Modal? and core.modal?
      #
      #   if core.modal['loading'] is undefined
      #     tmpl = 'loading'
      #     core.modal[tmpl] = new Modal.model tmpl, 'loading'
      #     core.modal[tmpl].toggleModal()
    )



  createList: () =>
    compiledTemplate = Handlebars.getTemplate('locations_listitem')
    # infoWindow = new google.maps.InfoWindow({
    #   content: compiledTemplate(location)
    # })

    # console.log @_properties.multi


  createMap: () =>

    zoom = if @_properties.multi then 8 else 15

    center =
      unless @_properties.multi
        center = new google.maps.LatLng(
          @_properties.locations[0].lat, @_properties.locations[0].lng
        )
      else center = null

    if @_properties.multi then styles = googleapis._properties.styles.multi

    if window.location.host.split('.')[0] is 'network'
      zoom = 6
      styles = googleapis._properties.styles.network


    @_properties.mapOptions =
      zoom: zoom
      scrollwheel: false
      draggable: !core.isMobile()
      center: center
      disableDefaultUI: true
      styles: styles


    @_properties.map = new google.maps.Map(
      @_properties.target, @_properties.mapOptions
    )

    if @_properties.multi
      @.createMarker location for location in @_properties.locations
      @.fitBounds()
        .bindResize(@.fitBounds)

    else
      @.createMarker @_properties.locations[0]
      @.setCenter()
        .fitCenter().bindResize(@.fitCenter)

      google.maps.event.addDomListener(@_properties.map, 'idle', () =>
        @.setCenter()
      )

    @.bindZoom()

    if @_properties.multi
      @.findClosest()


    @_properties.service = new google.maps.DistanceMatrixService()
    @_properties.geocoder = new google.maps.Geocoder()

    return @_properties.map



  createNewMarker: (location) =>

    if typeof location is 'string'

      @_properties.geocoder.geocode({
        "address" : location
      }, (results, status) =>

        if status is "OK"
          campusLatLng =
            lat: results[0].geometry.location.lat(),
            lng: results[0].geometry.location.lng()

          @.createMarker campusLatLng


      )
    else @.createMarker location

    this



  createMarker: (location) =>

    if google?
      campusLatLng = new google.maps.LatLng(
        location.lat, location.lng
      )

      img =
        if (location.img?)
            location.img
        else
            googleapis._properties.img

      url =
        # if @_properties.multi
        location.url
        # location.data-panel-show
        # else location.directions


      compiledTemplate = Handlebars.getTemplate('locations_popup')
      infoWindow = new google.maps.InfoWindow({
        content: compiledTemplate(location)
      })

      marker = new google.maps.Marker({
        _id: location._id
        position: campusLatLng
        map: @_properties.map
        title: location.campus
        url: url
        icon: img
        zIndex: location.count
        infoWindow: infoWindow
      })

      google.maps.event.addListener(marker, 'click', @.locationClicked(marker))

      # If campus list exists let's turn on the functionality for click events
      if document.querySelectorAll('[data-campus-item]').length != 0 then @.campusClickListener()

      @_properties.markers.push marker

    this

  closeAllMarkers: () =>
    for markers in @_properties.markers
      markers.infoWindow.close()

  # Find Campus Items, Add Click Listener to open Marker
  campusClickListener: () =>

    campusItems = document.querySelectorAll('[data-campus-item]')

    for campusItem in campusItems
      campusTarget =  campusItem.getAttribute('data-campus-item')
      campusItem.addEventListener('click', @.campusClicked(campusTarget))

  campusClicked: (campusTarget) =>
    () =>
      # console.log campusTarget
      # window.location.href = marker.url
      for markers in @_properties.markers
        unless markers._id.toLowerCase() is campusTarget.toLowerCase() then markers.infoWindow.close()

        if markers._id.toLowerCase() is campusTarget.toLowerCase()
          markers.infoWindow.open(@_properties.map, markers)

      # Add Active Class To Location Item
      inactiveCampus = []

      for location in document.querySelectorAll('[data-campus-item]')
        locationValue = location.getAttribute('data-campus-item')
        if locationValue is campusTarget
          activeCampus = location
        else
          inactiveCampus.push(location)

      @.activeLocation(inactiveCampus, activeCampus)

  locationClicked: (marker) =>
    () =>
      # window.location.href = marker.url
      for markers in @_properties.markers
        unless markers._id.toLowerCase() is marker._id.toLowerCase() then markers.infoWindow.close()
      marker.infoWindow.open(@_properties.map, marker)

      # Add Active Class To Location Item
      inactiveCampus = []

      for location in document.querySelectorAll('[data-campus-item]')
        locationValue = location.getAttribute('data-campus-item')
        if locationValue is marker._id
          activeCampus = location
        else
          inactiveCampus.push(location)

      @.activeLocation(inactiveCampus, activeCampus)

  setCenter: () =>
    @_properties.center = @_properties.map.getCenter()

    this

  fitCenter: () =>

    @_properties.map.setCenter(@_properties.center )

    this


  fitBounds: () =>
    bounds = new google.maps.LatLngBounds()

    for marker in @_properties.markers
      bounds.extend marker.getPosition()

    @_properties.map.fitBounds bounds

    this



  bindResize: (cb) =>

    debounce = core.debounce cb
    window.addEventListener('resize', debounce, false)

    this



  bindZoom: () =>
    zoomIn = document.querySelectorAll(
      '[' + @_properties.attr + '-zoom-in="' + @_properties._id + '"]'
    )[0]

    zoomOut = document.querySelectorAll(
      '[' + @_properties.attr + '-zoom-out="' + @_properties._id + '"]'
    )[0]

    zoom = @_properties.map.getZoom()

    google.maps.event.addDomListener(zoomIn, 'click', () =>
      zoom++
      @_properties.map.setZoom zoom
    )

    google.maps.event.addDomListener(zoomOut, 'click', () =>
      zoom--
      @_properties.map.setZoom zoom
    )

    this



  findClosest: () =>
    findClosest = document.querySelectorAll(
      '[' + @_properties.attr + '-closest="' + @_properties._id + '"]'
    )


    @_properties.findLocation = findClosest

    if google
      for trigger in findClosest

        if trigger.tagName is "INPUT"
          google.maps.event.addDomListener(trigger, 'blur', () =>

            #Close Existing Map Markers
            @.closeAllMarkers()

            @.events.emit('finding-closest')
            # console.log trigger, trigger.value
            @.getUserLocation([trigger.value])

            # Scroll to map
            document.querySelector('[data-geolocation-scroll]').scrollIntoView({block: "end", behavior: "smooth"})
          )
          google.maps.event.addDomListener(trigger, 'keypress', (e) =>
            if e.keyCode is 13

              #Close Existing Map Markers
              @.closeAllMarkers()

              # Blur to remove keyboard on mobile
              trigger.blur()

              @.events.emit('finding-closest')
              @.getUserLocation([trigger.value])

              # Scroll to map
              document.querySelector('[data-geolocation-scroll]').scrollIntoView({block: "end", behavior: "smooth"})
          )
        else
          google.maps.event.addDomListener(trigger, 'click', () =>
            @.events.emit('finding-closest')
            @.getUserLocation()
          )

    this

  getUserLocation: (location) =>

    returned = false

    saveLocation = (position) =>

      returned = true
      @_properties.userLocation =
        lat: position.coords.latitude
        lng: position.coords.longitude
        location: [
          new google.maps.LatLng(
            position.coords.latitude, position.coords.longitude
          )
        ]

      @.calculateDistance(@_properties.userLocation.location)

    failure = () =>

      returned = true
      for trigger in @_properties.findLocation
        # core.removeClass trigger, 'btn--icon btn--filled'
        trigger.innerHTML = 'Location services unavailable'

    if location
      @_properties.userLocation = {}
      if document.querySelector('[data-campus-list]')?
        @.campusSort(location)
      else
        @.calculateDistance(location)
    else
      callback = ->
        failure()
        return false

      timeout = setTimeout(callback, 15000)
      if navigator.geolocation
        navigator.geolocation
          .getCurrentPosition(
            (position) ->
              clearTimeout timeout
              saveLocation(position)
            ,
            () ->
              clearTimeout timeout
              failure()
          )

  campusSort: (location) =>

    if typeof location is "string"
      location = [location]
    cb = (response, status) =>
      if status is "OK"

        sorted = response.rows[0].elements.slice()

        campusList = []

        for campus in response.rows[0].elements.slice()

          for item in sorted

            if item.distance.value is campus.distance.value

              @_properties.userLocation or= {}
              currentCampus = @_properties.locations[_i]

              # Create an item in the campusList array
              campusItem = {
                _id  : "#{campus.distance.value}"
                distance : "#{campus.distance.text}"
                title : "#{currentCampus._id}"
                type : "#{currentCampus.type}"
                status: "#{currentCampus.status}"
                street1 : "#{currentCampus.location.street1}"
                street2 : "#{currentCampus.location.street2}"
                city : "#{currentCampus.location.city}"
                state : "#{currentCampus.location.state}"
                zip : "#{currentCampus.location.zip}"
                url : "#{currentCampus.url}"
              }

              # Inject that item in the campusList array
              campusList.push(campusItem)

        campusList.sort (a, b) ->
          a._id - b._id

        campusListTarget = document.querySelector('[data-campus-list]')

        campusListTarget.innerHTML = ""

        for campus in campusList

          campusItem = '<li data-campus-item="' + campus.title + '">
            <div class="soft-half soft--quarter-ends">
              <h6 class="float--right">' + campus.distance + '</h6>
              <h5>' + campus.title + (if campus.type is 'house' then ' <span class="superscript"><i class="fa fa-home color--info"></i></span>' else '') + '</h5>
              <small class="push-quarter--bottom portable-flush--bottom anchored-flush--bottom">' + (if campus.status is 'Coming Soon' then '<strong class="gray">Coming Soon</strong><br>' else '') + (if campus.street1 isnt 'false' then campus.street1 + '<br>' else '') + (if campus.street2 isnt 'false' then campus.street2 + '<br>' else '') + (if campus.city isnt 'false' then campus.city + ', ' else '') + (if campus.state isnt 'false' then campus.state + ' ' else '') + (if campus.zip isnt 'false' then campus.zip else '') + '</small>
              <br class="visuallyhidden--portable visuallyhidden--anchored">' +
            (if campus.status != 'Coming Soon' then '<a href="' + campus.url + '" class="link--arrow visuallyhidden--portable visuallyhidden--anchored flush">View Details</a>' else '') +
            '</div>
          </li>'

          campusListTarget.innerHTML = campusListTarget.innerHTML + campusItem

          # Attach Click Events Again
          @.campusClickListener()

          @.events.emit('campus-found', campusList[0])


        @.activeLocation(document.querySelectorAll('[data-campus-item]'), document.querySelectorAll('[data-campus-item]')[0])

    @_properties.service.getDistanceMatrix(
      origins: location
      destinations: @_properties.locations
      travelMode: google.maps.TravelMode.DRIVING
      unitSystem: google.maps.UnitSystem.IMPERIAL
      durationInTraffic: true
      avoidHighways: false
      avoidTolls: false
    , cb)

  # Add Active State to the first list item
  activeLocation: (allLocations, activeLocation)=>
    if allLocations.length?
      for location in allLocations
        core.removeClass location, "active"
    else
      core.removeClass allLocations, "active"
    core.addClass activeLocation, "active"

  calculateDistance: (location) =>

    if typeof location is "string"
      location = [location]
    cb = (response, status) =>
      if status is "OK"

        sorted = response.rows[0].elements.slice()

        sorted.sort( (a, b) ->

          if a.duration.value < b.duration.value then return -1
          if a.duration.value > b.duration.value then return 1
          return 0

        )

        for distance in response.rows[0].elements
          if distance.duration.value is sorted[0].duration.value
            @_properties.userLocation or= {}
            @_properties.userLocation.closestCampus = @_properties.locations[_i]
            @.events.emit('campus-found', @_properties.locations[_i])

    @_properties.service.getDistanceMatrix(
      origins: location
      destinations: @_properties.locations
      travelMode: google.maps.TravelMode.DRIVING
      unitSystem: google.maps.UnitSystem.IMPERIAL
      durationInTraffic: true
      avoidHighways: false
      avoidTolls: false
    , cb)

if core?
  callback = () ->
    window.googleapis = new Googleapis()

  core.addPlugin('Geolocation', Geolocation, '[data-geolocation]', callback)
