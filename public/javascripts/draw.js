// alert(window.orientation); // tabletのとき0, 90, 180, など

var canvas;
var uploadButton;
var colorButton = [];
var lineButton = [];
    
var width, height;
var canvasSize;
var orientation;
var canvasX, canvasY;
var context;
var lineWidth;
var strokeStyle;
var crd;
var drawing;

var gyazoUserID;
var gyazoImageID;

var browserWidth = function(){  
    if(window.innerWidth){ return window.innerWidth; }  
    else if(document.body){ return document.body.clientWidth; }  
    return 0;  
}

var browserHeight = function(){  
    if(window.innerHeight){ return window.innerHeight; }  
    else if(document.body){ return document.body.clientHeight; }  
    return 0;  
}

var resize = function(){
    window.devicePixelRatio = 1.0;

    width = browserWidth();
    height = browserHeight();
    canvasSize = width;
    if(height < canvasSize) canvasSize = height;

    if(gyazoImageID){
	var img = new Image();
	img.src = "/gyazodata/" + gyazoImageID; // + "?" + new Date().getTime();
	img.onload = function() {
	    context.drawImage(img, 0, 0);
	}
    }

    var orientation = 'portrait';

    if(window.orientation){
	if(window.orientation == '0' || window.orientation == '180'){
	    orientation = 'portrait';
	}
	else {
	    orientation = 'landscape';
	    var tmp = width;
	    width = height;
	    height = width;
	}
    }
    else {
	if(width > height){
	    orientation = 'landscape';
	}
	else {
	    orientation = 'portrait';
	}
    }
    
    canvas.attr('width',canvasSize);
    canvas.attr('height',canvasSize);

    context.fillStyle = '#FFF';
    context.fillRect(0,0,width,height);

    if(orientation == 'portrait'){
	var buttonWidth = width / 10;
	var buttonHeight = buttonWidth;
	var gap = (width - (buttonWidth * 7)) / 11;
	
	uploadButton.css('top',width+gap);
	uploadButton.css('left',gap);
	uploadButton.css('width',buttonWidth);
	uploadButton.css('height',buttonHeight);
	uploadButton.css('visibility','visible');
	
	for(var i=0;i<3;i++){
	    lineButton[i].css('top',width+gap);
	    lineButton[i].css('left',gap*3+buttonWidth+(buttonWidth+gap)*i);
	    lineButton[i].css('width',buttonWidth);
	    lineButton[i].css('height',buttonWidth);
	    lineButton[i].css('visibility','visible');
	}
	for(var i=0;i<3;i++){
	    colorButton[i].css('top',width+gap);
	    colorButton[i].css('left',gap*7+buttonWidth*4+(buttonWidth+gap)*i);
	    colorButton[i].css('width',buttonWidth);
	    colorButton[i].css('height',buttonWidth);
	    colorButton[i].css('visibility','visible');
	}
    }
    else {
	var buttonHeight = height / 10;
	var buttonWidth = buttonHeight;
	var gap = (height - (buttonHeight * 7)) / 11;
	
	uploadButton.css('top',gap);
	uploadButton.css('left',canvasSize+gap);
	uploadButton.css('width',buttonWidth);
	uploadButton.css('height',buttonHeight);
	uploadButton.css('visibility','visible');
	
	for(var i=0;i<3;i++){
	    lineButton[i].css('top',gap*3+buttonWidth+(buttonWidth+gap)*i);
	    lineButton[i].css('left',canvasSize+gap);
	    lineButton[i].css('width',buttonWidth);
	    lineButton[i].css('height',buttonHeight);
	    lineButton[i].css('visibility','visible');
	}
	for(var i=0;i<3;i++){
	    colorButton[i].css('top',gap*7+buttonWidth*4+(buttonWidth+gap)*i);
	    colorButton[i].css('left',canvasSize+gap);
	    colorButton[i].css('width',buttonWidth);
	    colorButton[i].css('height',buttonHeight);
	    colorButton[i].css('visibility','visible');
	}
    }
}

var initElements = function(){
  canvas = $('<canvas>');
  $('body').append(canvas);

  uploadButton = $('<input type="button">');
  uploadButton.css('position','absolute');
  uploadButton.css('visibility','hidden');
  uploadButton.attr('value','UP');
  $('body').append(uploadButton);

  for(var i=0;i<3;i++){
    lineButton[i] = $('<img>');
    lineButton[i].css('position','absolute');
    lineButton[i].css('visibility','hidden');
    lineButton[i].attr('src','/images/line'+(i+1)+'.png');
    $('body').append(lineButton[i]);
  }
  for(var i=0;i<3;i++){
    colorButton[i] = $('<img>');
    colorButton[i].css('position','absolute');
    colorButton[i].css('visibility','hidden');
    colorButton[i].attr('src','/images/color'+(i+1)+'.png');
    $('body').append(colorButton[i]);
  }
}

var initParams = function(){
    window.devicePixelRatio = 1.0;

    canvasX = canvas.offset()["left"];
    canvasY = canvas.offset()["top"];

    crd = {cur:{x:0,y:0},pre:{x:0,y:0}};
    drawing = false;
    lineWidth = 15;
    strokeStyle = "#000";

    context = canvas[0].getContext('2d');
    
    lineButton[0].on('click', function(e){ lineWidth = 3; });
    lineButton[1].on('click', function(e){ lineWidth = 15; });
    lineButton[2].on('click', function(e){ lineWidth = 30; });
    
    colorButton[0].on('click', function(e){ strokeStyle = 'rgb(255, 255, 255)'; });
    colorButton[1].on('click', function(e){ strokeStyle = 'rgb(128, 128, 128)'; });
    colorButton[2].on('click', function(e){ strokeStyle = 'rgb(0, 0, 0)'; });
}

var initCallbacks = function(){
    canvas.on('touchmove mousemove', function (e) {
	e.preventDefault();
	if ('touchmove' == e.type) {
            var x, y;
            x = e.originalEvent.changedTouches[0].pageX;
            y = e.originalEvent.changedTouches[0].pageY;
	} else {
            x = e.pageX;
            y = e.pageY;
	}
	x -= canvasX;
	y -= canvasY;
	
	if(x == width/2 && y == width/2) return; //GalaxyNexusのバグ回避
	
	if (drawing) {
            context.beginPath();
            context.lineJoin = "round";
            context.lineCap = "round";
	    context.strokeStyle = strokeStyle;
	    context.lineWidth = lineWidth;
            context.moveTo(crd.pre.x, crd.pre.y);
            crd.cur.x = x;
            crd.cur.y = y;
            context.lineTo(crd.cur.x, crd.cur.y);
            crd.pre.x = crd.cur.x;
            crd.pre.y = crd.cur.y;
            context.stroke();
            context.closePath();
	    
	} else {
            crd.pre.x = crd.cur.x;
            crd.pre.y = crd.cur.y;
            crd.cur.x = x;
            crd.cur.y = y;
	}
    });
    
    canvas.on('touchstart mousedown', function (e) {
	e.preventDefault();
	var x, y;
	if ('touchstart' == e.type) {
            x = e.originalEvent.changedTouches[0].pageX;
            y = e.originalEvent.changedTouches[0].pageY;
	} else {
            x = e.pageX;
            y = e.pageY;
	}
	x -= canvasX;
	y -= canvasY;
	crd.pre.x = x;
	crd.pre.y = y;
	drawing = true;
    });
    
    canvas.on('touchend mouseup', function (event) {
	event.preventDefault();
	drawing = false;
    });
    
    uploadButton.on('click', function(event){
	var imagedata = canvas[0].toDataURL(); // Gyazoからの画像を使ってるとセキュリティエラーになることあり
	// http://paulownia.hatenablog.com/entry/20100602/1275493299
	$.ajax({
            type: 'POST',
            url: '/upload',
            // crossDomain: true,
            data: {
		data: imagedata,
		id: gyazoUserID
            },
            success: function(data, textStatus, jqXHR ) {
		location.href = data;
            },
	});
    });

    $(window).on('resize',resize);
}
    
initElements();
initParams();
initCallbacks();
resize();
    

