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

    "width": 320,
    "height": 240,

    "swffile": "jslivecam.swf",
    "quality": 100,

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

    var source = '<object id="XwebcamXobjectX" type="application/x-shockwave-flash" data="'+webcam["swffile"]+'" width="'+webcam["width"]+'" height="'+webcam["height"]+'"><param name="movie" value="'+webcam["swffile"]+'" /><param name="FlashVars" value="mode='+webcam["mode"]+'&amp;quality='+webcam["quality"]+'" /><param name="allowScriptAccess" value="always" /></object>';

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
