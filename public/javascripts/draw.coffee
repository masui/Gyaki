#
# 「楽ギャキ」システム Gyaki.com
#  2013/01/05 11:43:09 masui
#

app = {}

browserWidth = ->
  return window.innerWidth if window.innerWidth
  return document.body.clientWidth if document.body
  0

browserHeight = ->
  return window.innerHeight if window.innerHeight
  return document.body.clientHeight if document.body
  0

resize = ->
  window.devicePixelRatio = 1.0;

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

  orientation = 'portrait'
  if window.orientation
    # タブレットのブラウザではwindow.orientationという値に
    # -90, 0, 90, 180 などの値が入る
   	if window.orientation == '0' || window.orientation == '180'
      orientation = 'portrait'
    else
      orientation = 'landscape'
      tmp = app.width
      app.width = app.height
      app.height = tmp
  else
    orientation = if app.width > app.height then 'landscape' else 'portraie'

  app.canvas.attr 'width', canvasSize
    .attr('height',canvasSize)
  app.context.fillStyle = '#FFF'
  app.context.fillRect(0,0,app.width,app.height)

  if orientation == 'portrait'
 	  buttonWidth = app.width / 10
 	  buttonHeight = buttonWidth
    gap = (app.width - (buttonWidth * 7)) / 11

    app.uploadButton.css 'top', app.width+gap
      .css 'left', gap
      .css 'width', buttonWidth
      .css 'height', nbuttonHeight
      .css 'visibility', 'visible'

    for i in [0...3]
 	    app.lineButton[i].css 'top', app.width+gap
        .css 'left', gap*3+buttonWidth+(buttonWidth+gap)*i
        .css 'width', buttonWidth
        .css 'height', buttonWidth
        .css 'visibility', 'visible'
      app.colorButton[i].css 'top', app.width+gap
        .css 'left', gap*7+buttonWidth*4+(buttonWidth+gap)*i
        .css 'width', buttonWidth
        .css 'height', buttonWidth
        .css 'visibility', 'visible'
  else # landscape
    buttonHeight = app.height / 10
    buttonWidth = buttonHeight
    gap = (app.height - (buttonHeight * 7)) / 11

    app.uploadButton.css 'top', gap
      .css 'left', canvasSize+gap
      .css 'width', buttonWidth
      .css 'height', buttonHeight
      .css 'visibility', 'visible'

    for i in [0...3]
      app.lineButton[i].css 'top', gap*3+buttonWidth+(buttonWidth+gap)*i
        .css 'left', canvasSize+gap
        .css 'width', buttonWidth
        .css 'height', buttonHeight
        .css 'visibility', 'visible'

      app.colorButton[i].css 'top', gap*7+buttonWidth*4+(buttonWidth+gap)*i
        .css 'left', canvasSize+gap
        .css 'width', buttonWidth
        .css 'height', buttonHeight
        .css 'visibility', 'visible'

initElements = ->
  app.canvas = $('<canvas>')
  $('body').append(app.canvas)

  app.uploadButton = $('<input type="button">')
    .css 'position', 'absolute'
    .css 'visibility', 'hidden'
    .attr 'value', 'UP'
  $('body').append(app.uploadButton)

  app.lineButton = []
  app.colorButton = []
  for i in [0...3]
    app.lineButton[i] = $('<img>')
      .css 'position', 'absolute'
      .css 'visibility', 'hidden'
      .attr 'src', '/images/line'+(i+1)+'.png'
    $('body').append(app.lineButton[i])

    app.colorButton[i] = $('<img>')
      .css 'position', 'absolute'
      .css 'visibility', 'hidden'
      .attr 'src', '/images/color'+(i+1)+'.png'
    $('body').append(app.colorButton[i])

initParams = ->
  window.devicePixelRatio = 1.0
 
  app.canvasX = app.canvas.offset()["left"]
  app.canvasY = app.canvas.offset()["top"]

  app.crd = {cur:{x:0,y:0},pre:{x:0,y:0}}
  app.drawing = false
  app.lineWidth = 15
  app.strokeStyle = "#000"

  app.context = app.canvas[0].getContext('2d')  # jQueryは配列になってるらしいのでこういう細工が必要

  app.lineButton[0].on 'click', (e) ->
    app.lineWidth = 3
  app.lineButton[1].on 'click', (e) ->
    app.lineWidth = 15
  app.lineButton[2].on 'click', (e) ->
    app.lineWidth = 30
  app.colorButton[0].on 'click', (e) ->
    app.strokeStyle = 'rgb(255, 255, 255)'
  app.colorButton[1].on 'click', (e) ->
    app.strokeStyle = 'rgb(128, 128, 128)'
  app.colorButton[2].on 'click', (e) ->
    app.strokeStyle = 'rgb(0, 0, 0)'

initCallbacks = ->
  app.canvas.on 'touchmove mousemove', (e) ->
    e.preventDefault()
    if 'touchmove' == e.type
      x = e.originalEvent.changedTouches[0].pageX
      y = e.originalEvent.changedTouches[0].pageY
    else
      x = e.pageX
      y = e.pageY
    x -= app.canvasX
    y -= app.canvasY
 
    return if x == app.width/2 && y == app.width/2 # GalaxyNexusのバグ? 回避

    if app.drawing
      # 線の属性はこのように毎回セットしないとうまく描けなかったりする
      app.context.beginPath()
      app.context.lineJoin = "round"
      app.context.lineCap = "round"
      app.context.strokeStyle = app.strokeStyle
      app.context.lineWidth = app.lineWidth
      app.context.moveTo app.crd.pre.x, app.crd.pre.y
      app.crd.cur.x = x
      app.crd.cur.y = y
      app.context.lineTo app.crd.cur.x, app.crd.cur.y
      app.crd.pre.x = app.crd.cur.x
      app.crd.pre.y = app.crd.cur.y
      app.context.stroke()
      app.context.closePath()
    else
      app.crd.pre.x = app.crd.cur.x
      app.crd.pre.y = app.crd.cur.y
      app.crd.cur.x = x
      app.crd.cur.y = y

  app.canvas.on 'touchstart mousedown', (e) ->
    e.preventDefault()
    if 'touchstart' == e.type
      x = e.originalEvent.changedTouches[0].pageX
      y = e.originalEvent.changedTouches[0].pageY
    else
      x = e.pageX
      y = e.pageY
    x -= app.canvasX
    y -= app.canvasY
    app.crd.pre.x = x
    app.crd.pre.y = y
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

initElements()
initParams()
initCallbacks()
resize()
