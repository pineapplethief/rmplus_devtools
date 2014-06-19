rmplus_devtools
===============

Collection of useful tools/patches for Redmine developers.

Plugin installs gems useful for profiling: rack-mini-profiler and oink, both can be enabled in the plugin settings. rack-mini-profiler can be conviniently enabled on production server only for selected users, making it possible to profile and debug in production environment without excessive overhead. Oink could be useful for debugging ActiveRecord queries, specially concerning memory consumption.

Plugin also optionally replaces redmine/public/plugin_assets contents with direct symlinks to plugins assets directories, removing the need to restart the server every time the developer edits javascript or css file. Such a feature speeds up front-end development for redmine a great deal, but is OS dependent, and will likely work only in Unix environment.

![logo](https://github.com/pineapple-thief/rmplus_devtools/raw/master/screenshots/logo.png)

[site]: http://rmplus.pro
You can check out more of our plugins here: [http://rmplus.pro][site]
