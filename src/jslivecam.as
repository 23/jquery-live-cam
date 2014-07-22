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

package {
  import flash.display.Sprite;
  import flash.system.Security;
  import flash.external.ExternalInterface;
  import flash.media.*;
  import flash.net.*;
  import flash.events.*;  
  
  public class jslivecam extends Sprite {
    private var camera:Camera = null;
    private var video:Video = null;
    private var nc:NetConnection;
    private var ns:NetStream;
    private var server:String = null;
    private var stream:String = null;
    private var h264Settings:H264VideoStreamSettings = null;

    public function jslivecam() {
      Security.allowDomain("*");
      NetConnection.defaultObjectEncoding = ObjectEncoding.AMF0;
      
      // Set up h264 encoding
      h264Settings = new H264VideoStreamSettings();
      h264Settings.setProfileLevel( H264Profile.BASELINE, H264Level.LEVEL_3_1);

      // Set up the camera
      camera = Camera.getCamera(); 
      if(camera==null) {
        ExternalInterface.call('webcam.debug', "error", "No camera was detected.");
        return;
      }
      cam.setMode(320, 240, 25, true);
      cam.setKeyFrameInterval(50);
      cam.setQuality(2000000, 100);
      camera.addEventListener(StatusEvent.STATUS, function(event:StatusEvent):void {
        switch(event.code) {
        case "Camera.Muted": 
	  ExternalInterface.call('webcam.debug', "notify", "Camera stopped");
          break; 
        case "Camera.Unmuted": 
	  ExternalInterface.call('webcam.debug', "notify", "Camera started");
          break; 
        } 
      });
      
      // Attach a video object for display
      video = new Video(camera.width, camera.height); 
      video.attachCamera(camera); 
      addChild(video);
      
      // Start and stop streaming
      ExternalInterface.addCallback("startStreaming", startStreaming);
      ExternalInterface.addCallback("stopStreaming", stopStreaming);
    }

    private function closeConnections():void {
      if (ns != null) {
        ns.close();
        ns = null;
      }
      if (nc != null) {
        nc.close();
        nc = null;
      }
    }

    public function startStreaming(server:String, stream:String):Boolean {
      // Clear previous connections
      closeConnections();

      // Remember state
      this.server = server;
      this.stream = stream;

      // Connect to the server
      nc = new NetConnection();
      nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
      nc.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
      nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler, false, 0, true);
      nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler, false, 0, true);
      nc.client = {};
      nc.connect(server);

      // That's kind it -- the success event should come back from the netStatusHandler event
      return true;
    }
    public function stopStreaming():Boolean {
      closeConnections();
      ExternalInterface.call("webcam.onStreamingStop", "");
      return true;
    }

    private function netStatusHandler(event:NetStatusEvent):void {
      ExternalInterface.call('webcam.debug', "notify", 'netStatusHandler() ' + event.type + ' ' + event.info.code);
      switch (event.info.code) {
      case 'NetConnection.Connect.Success':
        ExternalInterface.call('webcam.debug', "notify", 'connected = ' + nc.connected);
        // Connect a stream and publish it
        ns = new NetStream(nc);
        hs.videoStreamSettings = h264Settings;
        ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
        ns.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
        ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler, false, 0, true);
        ns.attachCamera(Camera.getCamera());
        //ns.attachAudio(Microphone.getMicrophone(-1));

        // Send some meaningful meta data to the server
        ns_out.send( "@setDataFrame", "onMetaData", {
          codec: ns_out.videoStreamSettings.codec,
          audiocodecid:5,
	  profile:  h264Settings.profile,
	  level: h264Settings.level,
	  fps: cam.fps,
	  bandwith: cam.bandwidth,
	  height: cam.height,
	  width: cam.width,
	  keyFrameInterval: cam.keyFrameInterval
        });

        ExternalInterface.call('webcam.debug', "notify", 'publish stream = ' + this.stream);
        
        ns.publish(this.stream, 'live');
        ExternalInterface.call("webcam.onStreamingStart", "");
        break;
      case 'NetConnection.Connect.Failed':
      case 'NetConnection.Connect.Reject':
      case 'NetConnection.Connect.Closed':
        stopStreaming();
        break;
      case 'NetStream.Play.Stop':
        stopStreaming();
        break;
      }
    }
    
    private function errorHandler(event:ErrorEvent):void {
      stopStreaming();
    }
  }
}