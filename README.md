


Running the server-side
-----------------------

https://github.com/raspberrypi/libcamera

```sh
LIBCAMERA_LOG_LEVELS=*:DEBUG

export GST_PLUGIN_SYSTEM_PATH_1_0=/nix/store/wlrmb5096gyi5xswy79kn6lpaj2b8p19-gstreamer-1.24.3/lib/gstreamer-1.0/

sudo gst-launch-1.0 libcamerasrc ! \
     video/x-raw,colorimetry=bt709,format=NV12,width=1280,height=720,framerate=30/1 ! \
     queue ! jpegenc ! multipartmux ! \
     tcpserversink host=0.0.0.0 port=5000
```


https://github.com/raspberrypi/rpicam-apps



