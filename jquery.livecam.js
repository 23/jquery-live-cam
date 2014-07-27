/**
* @see http://github.com/23/jquery-live-cam/

* A fair bit of this code originated from:
*
* jQuery webcam
* Copyright (c) 2010, Robert Eisele (robert@xarg.org)
* Dual licensed under the MIT or GPL Version 2 licenses.
* @author Robert Eisele
* @version 1.0
*
**/

(function ($) {

  var webcam = {
    "extern": null, // external select token to support jQuery dialogs
    "append": true, // append object instead of overwriting

    "bgcolor":"#000000",
    "canvasWidth": 640,
    "canvasHeight": 360,

    "swffile": "jslivecam.swf",
    "quality": 100,
    "frameRate": 25,
    "keyFrameInterval": 50,
    "bitrate": 1000000,
    "width": 1280,
    "height": 720,

    "debug":	function () {},
    "onStreamingStart":	function() {},
    "onStreamingStop":	function() {},
    "onLoad":	function () {}
  };

  window["webcam"] = webcam;

  $["fn"]["webcam"] = function(options) {

    if (typeof options === "object") {
      for (var ndx in webcam) {
	if (options[ndx] !== undefined) {
	  webcam[ndx] = options[ndx];
	}
      }
    }

    var source = '<object id="XwebcamXobjectX" type="application/x-shockwave-flash" bgcolor="'+webcam["bgcolor"]+'" data="'+webcam["swffile"]+'" width="'+webcam["canvasWidth"]+'" height="'+webcam["canvasHeight"]+'"><param name="movie" value="'+webcam["swffile"]+'" /><param name="allowScriptAccess" value="always" /></object>';

    if (null !== webcam["extern"]) {
      $(webcam["extern"])[webcam["append"] ? "append" : "html"](source);
    } else {
      this[webcam["append"] ? "append" : "html"](source);
    }

    var run = 3;
    (_register = function() {
      var cam = document.getElementById('XwebcamXobjectX');

      if (cam && cam["startStreaming"] !== undefined) {

	/* Simple callback methods are not allowed :-/ */
  	webcam["startStreaming"] = function(x,y) {
	  try {
	    return cam["startStreaming"](x,y);
	  } catch(e) {}
	}
	webcam["stopStreaming"] = function() {
	  try {
	    return cam["stopStreaming"]();
	  } catch(e) {}
	}
        
        cam["bootstrap"](webcam.width, webcam.height, webcam.frameRate, webcam.keyFrameInterval, webcam.quality, webcam.bitrate);
	webcam["onLoad"]();
      } else if (0 == run) {
	webcam["debug"]("error", "Flash movie not yet registered!");
      } else {
	/* Flash interface not ready yet */
	run--;
	window.setTimeout(_register, 1000 * (4 - run));
      }
    })();
  }

})(jQuery);
