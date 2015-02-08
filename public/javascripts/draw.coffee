#
# 「楽ギャキ」システム Gyaki.com
#  2013/01/05 11:43:09 masui
#  2015/01/04 23:20:10 Cofferに書き直し
#

app = {}

$ -> 
  initElements()
  initParams()
  initCallbacks()
  resize()

browserWidth = ->
  return window.innerWidth if window.innerWidth
  return document.body.clientWidth if document.body
  0

browserHeight = ->
  return window.innerHeight if window.innerHeight
  return document.body.clientHeight if document.body
  0

resize = ->
  window.devicePixelRatio = 1.0

  app.width = browserWidth()
  app.height = browserHeight()
  canvasSize = if app.height < app.width then app.height else app.width
  
  if gyazoImageID
    # http://paulownia.hatenablog.com/entry/20100602/1275493299
    # Gyazo.comから画像を取得するとクロスドメインでエラーになるので
    # Gyaki.com/gyazodataから間接的に画像を取得する
    img = new Image()
   	img.src = "/gyazodata/#{gyazoImageID}"
   	img.onload = ->
      app.context.drawImage(img, 0, 0)

  orientation = 
    if window.orientation
      # タブレットのブラウザではwindow.orientationという値に
      # -90, 0, 90, 180 などの値が入る
     	if window.orientation == '0' || window.orientation == '180'
        'portrait'
      else
        [app.width, app.height] = [app.height, app.width]
        'landscape'
    else
      if app.width > app.height
        'landscape'
      else
        'portrait'

  app.canvas
    .attr 'width', canvasSize
    .attr 'height', canvasSize
  app.context.fillStyle = '#FFF'
  app.context.fillRect 0, 0, app.width, app.height
  alert "fillrect"

  if orientation == 'portrait'
 	  buttonWidth = app.width / 10
 	  buttonHeight = buttonWidth
    gap = (app.width - (buttonWidth * 7)) / 11

    app.uploadButton
      .css 'top', app.width+gap
      .css 'left', gap
      .css 'width', buttonWidth
      .css 'height', nbuttonHeight
      .css 'visibility', 'visible'

    for i in [0...3]
 	    app.lineButtons[i]
        .css 'top', app.width+gap
        .css 'left', gap*3+buttonWidth+(buttonWidth+gap)*i
        .css 'width', buttonWidth
        .css 'height', buttonWidth
        .css 'visibility', 'visible'
      app.colorButtons[i]
        .css 'top', app.width+gap
        .css 'left', gap*7+buttonWidth*4+(buttonWidth+gap)*i
        .css 'width', buttonWidth
        .css 'height', buttonWidth
        .css 'visibility', 'visible'
  else # landscape
    buttonHeight = app.height / 10
    buttonWidth = buttonHeight
    gap = (app.height - (buttonHeight * 7)) / 11

    app.uploadButton
      .css 'top', gap
      .css 'left', canvasSize+gap
      .css 'width', buttonWidth
      .css 'height', buttonHeight
      .css 'visibility', 'visible'

    for i in [0...3]
      app.lineButtons[i]
        .css 'top', gap*3+buttonWidth+(buttonWidth+gap)*i
        .css 'left', canvasSize+gap
        .css 'width', buttonWidth
        .css 'height', buttonHeight
        .css 'visibility', 'visible'

      app.colorButtons[i]
        .css 'top', gap*7+buttonWidth*4+(buttonWidth+gap)*i
        .css 'left', canvasSize+gap
        .css 'width', buttonWidth
        .css 'height', buttonHeight
        .css 'visibility', 'visible'

initElements = ->
  app.canvas = $('<canvas>')
  $('body').append app.canvas

  app.uploadButton = $('<input type="button">')
    .css 'position', 'absolute'
    .css 'visibility', 'hidden'
    .attr 'value', 'UP'
  $('body').append app.uploadButton

  app.lineButtons = for i in [0...3]
    $('<img>')
      .css 'position', 'absolute'
      .css 'visibility', 'hidden'
      .attr 'src', "/images/line#{i+1}.png"
  $('body').append button for button in app.lineButtons

  app.colorButtons = for i in [0..3]
    $('<img>')
      .css 'position', 'absolute'
      .css 'visibility', 'hidden'
      .attr 'src', "images/color#{i+1}.png"
  $('body').append button for button in app.colorButtons

initParams = ->
  window.devicePixelRatio = 1.0
 
  app.canvasX = app.canvas.offset()["left"]
  app.canvasY = app.canvas.offset()["top"]

  app.crd = {cur: [0, 0], pre: [0, 0]}
  app.drawing = false
  app.lineWidth = 15
  app.strokeStyle = "#000"

  app.context = app.canvas[0].getContext('2d')  # jQueryは配列になってるらしいのでこういう細工が必要

  app.lineButtons[0].on 'click', (e) ->
    app.lineWidth = 3
  app.lineButtons[1].on 'click', (e) ->
    app.lineWidth = 15
  app.lineButtons[2].on 'click', (e) ->
    app.lineWidth = 30
  app.colorButtons[0].on 'click', (e) ->
    app.strokeStyle = 'rgb(255, 255, 255)'
  app.colorButtons[1].on 'click', (e) ->
    app.strokeStyle = 'rgb(128, 128, 128)'
  app.colorButtons[2].on 'click', (e) ->
    app.strokeStyle = 'rgb(0, 0, 0)'

initCallbacks = ->
  app.canvas.on 'touchmove mousemove', (e) ->
    e.preventDefault()
    [x, y] =
      if 'touchmove' == e.type
        [e.originalEvent.changedTouches[0].pageX, e.originalEvent.changedTouches[0].pageY]
      else
        [e.pageX, e.pageY]
    [x, y] = [x - app.canvasX, y - app.canvasY]

    return if x == app.width/2 && y == app.width/2 # GalaxyNexusのバグ? 回避

    if app.drawing
      # preからcurまで線を引く
      # 線の属性はこのように毎回セットしないとうまく描けなかったりする...
      app.context.beginPath()
      app.context.lineJoin = "round"
      app.context.lineCap = "round"
      app.context.strokeStyle = app.strokeStyle
      app.context.lineWidth = app.lineWidth
      app.context.moveTo app.crd.pre[0], app.crd.pre[1]
      app.crd.cur = [x, y]
      app.context.lineTo app.crd.cur[0], app.crd.cur[1]
      app.crd.pre = app.crd.cur
      app.context.stroke()
      app.context.closePath()

  app.canvas.on 'touchstart mousedown', (e) ->
    e.preventDefault()
    [x, y] =
      if 'touchstart' == e.type
        [e.originalEvent.changedTouches[0].pageX, e.originalEvent.changedTouches[0].pageY]
      else
        [e.pageX, e.pageY]
    app.crd.pre = [x - app.canvasX, y - app.canvasY]
    app.drawing = true

  app.canvas.on 'touchend mouseup', (e) ->
    e.preventDefault()
    app.drawing = false

  app.uploadButton.on 'click', (e) ->
    imagedata = app.canvas[0].toDataURL()
    $.ajax
      type: 'POST'
      url: '/upload'
      data:
        data: imagedata
        id: gyazoUserID
      success: (data, textStatus, jqXHR ) ->
        location.href = data  # Gyazoページに移動

  $(window).on 'resize', resize
