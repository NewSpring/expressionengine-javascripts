###

@class NewSpringPlayer

@author
  Brian Kalwat
  NewSpring Church

@version 2.0

###

# Create a video modal
createVideoModal = ->
  
  # Create a new div element 
  videoPlayerContainer = document.createElement('div')

  # Add modal class to element
  videoPlayerContainer.classList.add 'modal'

  # Add data-modal attribute + value to element
  videoPlayerContainer.dataset.modal = 'videoPlayer'

  # Add modal contents to element
  videoPlayerContainer.innerHTML = '<div id="player--wistia"></div>' + 
  '<div class="icon icon--close-modal fa fw fa-times" data-modal-close="videoPlayer"></div>'

  # Append element to document body
  document.body.append videoPlayerContainer

  return


# Destroy video (should not remove modal element from page)
destroyVideo = (modal) ->

  # Clear out wistia embed code
  modal.querySelector('#player--wistia').innerHTML = ''

  # Remove active class from modal to make it disappear
  modal.classList.remove 'modal--active'

  # Remove modal--opened class from html that locks scrolling
  document.querySelector('html').classList.remove 'modal--opened'

  return

# Get data-video elements on page and create an array
videos = document.querySelectorAll('[data-video]')

# If page has videos, run createVideoModal to create video modal on page			
if videos.length >= 1
  createVideoModal()

# Bind click events to elements with data-video
i = 0
while i < videos.length

  # Set trigger to element of loop instance
  trigger = videos[i]

  trigger.onclick = ->

    # Set video modal
    videoModal = document.querySelector('[data-modal="videoPlayer"]')

    # Set video modal close trigger
    videoModalClose = videoModal.querySelector('[data-modal-close]')

    # Bind destroyVideo function to videoModalClose element
    videoModalClose.onclick = ->

      destroyVideo videoModal

      return

    # Set target element
    target = document.querySelector('#player--wistia')

    # Get data-video value and create array
    dataVideo = @getAttribute('data-video').split(',')

    # Get Wistia hash and trim spaces
    videoHash = dataVideo[1].trim(' ')

    # Set Wistia embed script url
    wistiaEmbedScript = document.createElement('script')
    wistiaEmbedScript.type = 'text/javascript'
    wistiaEmbedScript.setAttribute 'async', ''
    wistiaEmbedScript.src = 'https://fast.wistia.com/embed/medias/' + videoHash + '.jsonp'

    # Set Wistia asset script url
    wistiaAssetScript = document.createElement('script')
    wistiaAssetScript.type = 'text/javascript'
    wistiaAssetScript.setAttribute 'async', ''
    wistiaAssetScript.src = 'https://fast.wistia.com/assets/external/E-v1.js'

    # Generate Wistia player HTML
    playerHtml = '<div class="wistia_responsive_padding" style="padding:56.25% 0 0 0;position:relative;">' + 
    '<div class="wistia_responsive_wrapper" style="height:100%;left:0;position:absolute;top:0;width:100%;">' + 
    '<div class="wistia_embed wistia_async_' + videoHash + ' videoFoam=true autoPlay=true" style="height:100%;width:100%">&nbsp;</div>' + 
    '</div>' + '</div>'

    # Add Wistia player HTML
    target.innerHTML = playerHtml

    # Add Wistia embed script
    target.append wistiaEmbedScript

    # Add Wistia asset script
    target.append wistiaAssetScript

    # Activate player modal
    target.parentNode.classList.add 'modal--active'

    # Add modal opened class to html element
    document.querySelector('html').classList.add 'modal--opened'

    return

  i++