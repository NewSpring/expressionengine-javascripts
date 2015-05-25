###
@class Googleapis, Geolocation

@author
  James E Baxley III
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
              stylers: [visibility: "off"]
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
              stylers: [lightness: 50]
            }
            {
              featureType: "road"
              elementType: "labels"
              stylers: [visibility: "off"]
            }
            {
              featureType: "transit"
              stylers: [visibility: "off"]
            }
            {
              featureType: "administrative"
              elementType: "geometry"
              stylers: [lightness: 40]
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

    locations = try JSON.parse(params[2]); catch e then console.log e

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

      # for marker in @_properties.markers
      #
      #   if marker.url is ('/locations/' + campus.url)
      #     marker.infoWindow.open(@_properties.map, marker)
      window.location.href = campus.url
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

      @_properties.markers.push marker

    this



  locationClicked: (marker) =>
    () =>
      window.location.href = marker.url
      # for markers in @_properties.markers
      #   unless markers._id.toLowerCase() is marker._id.toLowerCase() then markers.infoWindow.close()
      # marker.infoWindow.open(@_properties.map, marker)



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
            @.events.emit('finding-closest')
            @.getUserLocation([trigger.value])
          )
          google.maps.event.addDomListener(trigger, 'keyup', (e) =>
            if e.keyCode is 13
              @.events.emit('finding-closest')
              @.getUserLocation([trigger.value])
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
        core.removeClass trigger, 'btn--icon btn--filled'
        trigger.innerHTML = 'Location services unavailable'


    if location
      @_properties.userLocation = {}
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




  calculateDistance: (location) =>

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
