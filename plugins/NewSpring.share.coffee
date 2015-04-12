###
@class Share

@author
  Rich Dubay
  NewSpring Church

@version 0.1

@note
  social share highlighted text

###

class Share

  constructor: (@data, attr) ->

    # Check and see if called by jQuery and convert to node
    if @data instanceof jQuery then @data = @data.get(0)

    # Get data from attribute
    params = @data.attributes[attr].value.split(/[,](?=[^\]]*?(?:\[))(?=[^\}]*?(?:\{))/g)
    params = params.map (param) -> param.trim()

    if params.length > 3
      meta = params.splice(0, 2)
      json = params.join(',')
      params = meta.concat json

    hashtags = try JSON.parse(params[1]).hashtags catch e then {}

    @_properties = {
      target: @data
      _id: params[0]
      attr: attr
      text: null
      handle: document.querySelectorAll('[name="twitter:creator"]')[0].content.replace('@','') ? "newspring"
      url: document.querySelectorAll('[property="short_url"]')[0].content ? "http://newspring.cc"
      longUrl: window.location.href
      hashtags: hashtags ? false
      subject: document.getElementsByTagName('title')[0].innerText ? "Ask Next Steps About This Subject Line"
    }

    if EventEmitter? then @.events = new EventEmitter()

    @.showMenu()
    @.bindWatch().bindClick()


  bindWatch: =>

    @_properties.target.onmousedown = @.md
    document.onmousedown = @.dmd
    @_properties.target.onmouseup = @.watch
    this


  dmd: (event) =>
    @_properties.dmdy = event.pageY
    if @_properties.dmdy isnt @_properties.mdy and event.target.parentNode.dataset.shareButton is undefined
      el = document.getElementById("share")
      core.removeClass el, "share-menu-active"

  md: (event) =>
    @_properties.mdy = event.pageY
    @_properties.mdx = event.pageX


  watch: (event) =>

    selection = document.getSelection()
    text = selection.toString()
    range = selection.getRangeAt(0).cloneRange()
    boundary = range.getBoundingClientRect()
    if range.getClientRects
      range.collapse(true)
      rec = range.getClientRects()[0];
      y = rec.top;
      top = document.body.scrollTop + y


    rect = range.getClientRects()[0]
    el = document.getElementById("share")
    unless text is ""

      core.addClass el, "share-menu-active"
      @_properties.text = text

      if event.target.parentNode.dataset.shareButton is undefined

        if (@_properties.mdy isnt event.pageY and @_properties.dmdy isnt event.pageY) or (@_properties.mdx isnt event.pageX)

          top = top - el.offsetHeight - 10; # the 10 is for the arrow

          el.setAttribute(
            'style',
            'top:' + top + 'px;'
          )

          style = el.getAttribute('style')

          left = ((rect.left + boundary.right) /2) - (el.offsetWidth/2)
          if left < 0
            left = 0

          style = style + "left:" + left + 'px;'
          el.setAttribute('style', style)

        else

          core.removeClass el, "share-menu-active"

    else

      core.removeClass el, "share-menu-active"


  showMenu: =>
    template = 'share'
    compiledTemplate = Handlebars.getTemplate(template)
    if typeof compiledTemplate is 'function'
      temp = document.createElement 'div'
      temp.innerHTML = compiledTemplate()
      document.body.appendChild(temp)


  share: (event) =>
    event.preventDefault()
    shareText = @_properties.text
    # shareUrl = "http:" + encodeURIComponent(window.location.href.slice(window.location.href.indexOf('//')))
    # shareUrl = encodeURIComponent("http:" + window.location.href.slice(window.location.href.indexOf('//')))
    shareUrl = encodeURIComponent("http:" + @_properties.url.slice(@_properties.url.indexOf('//')))
    shareLongUrl = encodeURIComponent("http:" + @_properties.longUrl.slice(@_properties.longUrl.indexOf('//')))

    shareHandle = ""
    if @_properties.handle
      shareHandle = "via @" + @_properties.handle

    shareHashtagList = ""
    hashtagCount = 0
    if @_properties.hashtags
      for hashtag in @_properties.hashtags
        shareHashtagList += hashtag + ', '
        hashtagCount++
      shareHashtagList = shareHashtagList.slice(0, shareHashtagList.length-2)

    # what do the url, handle, and hashtags add up to?
    shareString = ""
    if shareUrl.length > 0
      shareString += shareUrl + " "
    if shareHandle.length > 0
      shareString += shareHandle + " "
    if shareHashtagList.length > 0
      shareString += shareHashtagList

    shareData =
      shareHandle: shareHandle
      shareString: shareString
      shareText: '\"' + shareText + '\"'
      shareUrl: shareUrl
      shareLongUrl: shareLongUrl
      shareHashtagList: shareHashtagList.replace(' ','')
      hashtagCount: hashtagCount
      emailSubject: encodeURIComponent(@_properties.subject.trim())

    if event.target.parentNode.id is "twitter-share-button"
      @.tweet(shareData)
    else if event.target.parentNode.id is "email-share-button"
      @.email(shareData)
    else console.log 'facebook can go here'


  tweet: (tweet) =>

    whatIsLeftOver = 140 - tweet.shareString.length
    if tweet.shareText.length > whatIsLeftOver
      # subtract from whatIsLeftOver:
      # 5 because you're going to need to add the ... and a " at the beginning and end
      # 1 for the space that will be auto added after the text
      # and 1 for each of the hashtags in the list.
      whatIsLeftOver -= tweet.hashtagCount + 6
      tweet.shareText = tweet.shareText.slice(0, whatIsLeftOver)
      tweet.shareText += "...\""

    # open a new tab with the twitter stuff
    twitterShareUrl = "https://twitter.com/intent/tweet?"
    twitterShareUrl += "text=" + encodeURIComponent(tweet.shareText)
    twitterShareUrl += "&url=" + tweet.shareUrl
    if @_properties.handle
      twitterShareUrl += "&via=" + @_properties.handle

    if @_properties.hashtags
      twitterShareUrl += "&hashtags=" + tweet.shareHashtagList

    el = document.getElementById("share")
    core.removeClass el, "share-menu-active"
    document.getSelection().removeAllRanges()
    window.open(twitterShareUrl, '_blank', 'location=yes,height=420,width=550')

  email: (shareData) =>

    newline = "\r\n"
    emailSubject = shareData.emailSubject
    emailBody = "I found this on " + shareData.shareLongUrl + "<br /><br />" + encodeURIComponent(shareData.shareText)
    mailtoLink = "mailto:?subject=" + emailSubject + "&body=" + emailBody
    el = document.getElementById("share")
    core.removeClass el, "share-menu-active"
    document.getSelection().removeAllRanges()
    window.location.href = mailtoLink

  bindClick: =>
    # Find the trigger for the share
    triggers = document.querySelectorAll('[data-share-button]')

    for trigger in triggers
      @_properties.trigger = trigger
      trigger.addEventListener 'click', @.share, false


if core?
  core.addPlugin("Share", Share, '[data-share]' )
