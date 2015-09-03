
var VIIW = { REVISION: 0 };

VIIW.setLayers = function( containerName, perspective, layers ) {
  this.containerName = containerName;
  this.perspective = perspective;
  this.layers = layers;
}

VIIW.init = function() {
  this.containerElem = document.getElementById( this.containerName );

  for ( var i = 0, n = this.layers.length; i < n; i++ ) {
    var layer = this.layers[ i ]
    this.layers[ i ].elem = document.getElementById( layer.id );
    this.layers[ i ].elem.style.width = "100%";
    this.layers[ i ].elem.style.position = "absolute";
  }

  if ( VIIW.postInit ) {
    VIIW.postInit();
  }

  this.introScale = 2;
  this.amx = 0;
  this.amy = 0;
  this.update( 0, 0 );

  document.body.onmousemove = VIIW.onmousemove;
}

VIIW.onmousemove = function( event ) {
  var mouseX = event.clientX;
  var mouseY = event.clientY;
  var width = VIIW.containerElem.offsetWidth;
  var height = width / ( 16 / 10 );

  var mx = ( mouseX - width / 2 ) / width;
  var my = ( mouseY - height / 2 ) / height;

  VIIW.update( mx, my );
}

VIIW.update = function( mx, my ) {
  VIIW.mx = mx;
  VIIW.my = my;

  if ( !VIIW.animRunning ) {
    setTimeout( VIIW.performAnimation, 50 ); // 20 fps
    VIIW.animRunning = true;
  }
}

VIIW.performAnimation = function() {
  //  console.log( "+" );

  var amx = VIIW.amx = ( VIIW.amx * 0.95 + VIIW.mx * 0.05 );
  var amy = VIIW.amy = ( VIIW.amy * 0.95 + VIIW.my * 0.05 );

  var width = VIIW.containerElem.offsetWidth;
  var height = width / ( 16 / 10 );
  var iScale = VIIW.introScale;

  for ( var i = 0, n = VIIW.layers.length; i < n; i++ ) {
    var layer = VIIW.layers[ i ];

    var targetLeft = layer.hFactor * amx;
    var targetTop  = layer.vFactor * amy;

    var targetRotH = layer.hRotFactor * amx;
    var targetRotV = layer.vRotFactor * amy;

    layer.elem.style.webkitTransform =
    "perspective(" + ( width * VIIW.perspective ) + ") " +
    "translate3d("
    + ( ( targetLeft + layer.hBias ) * width ) + "px, "
    + ( ( targetTop  + layer.vBias ) * height ) + "px, "
    + ( layer.zBias * width) + "px) " +
    "rotateY( "
    + ( targetRotH + layer.hRotBias ) + "deg ) " +
    "rotateX( "
    + ( targetRotV + layer.vRotBias ) + "deg ) " +
    "scale("
    + ( layer.scale * iScale ) + ") ";
  }
  VIIW.introScale = 1 + ( VIIW.introScale - 1 ) * 0.8;

  if ( Math.abs( VIIW.amx - VIIW.mx ) < 0.001
      && Math.abs( VIIW.amy - VIIW.my ) < 0.001
      && iScale < 1.001 ) {
    VIIW.animRunning = false;
  } else {
    setTimeout( VIIW.performAnimation, 50 );
  }
}
