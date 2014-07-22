jQuery Webcam Plugin
====================

Description
-----------
A small wrapper library to be able to stream to an RTMP server via JavaScript.


Example
------

Please note: The camera doesn't work if you have any dom-errors on your page!

The Flash object will be embedded into the following Div:

```html
<div id="webcam"></div>
<button id="start-btn" onclick="webcam.startStreaming('rtmp url', 'stream name')">&#9658;</button>
<button id="stop-btn" onclick="webcam.stopStreaming();">&#9632;</button>```

```javascript

jQuery("#webcam").webcam({
	width: 320,
	height: 240,
	swffile: "/jslivecam.swf", 

    debug: function (type, string) {
      console.debug(type, string);
    },
    onLoad: function () {
      console.debug('onLoad');
    },
    onStreamingStart: function () {
      console.debug('onStreamingStart');
    },
    onStreamingStop: function () {
      console.debug('onStreamingStop');
    }
});

```


Acknowledgement
==========================
This code was has made liberal use of the library at:

http://www.xarg.org/project/jquery-webcam-plugin/

License
======
Dual licensed under the MIT or GPL Version 2 licenses.
