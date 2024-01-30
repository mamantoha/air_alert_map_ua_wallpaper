# air_alert_map_ua_wallpaper

A CLI tool for setting the Air Raid Alert Map of Ukraine as a desktop background

![preview](preview.png)

## About

This script takes a screenshot of the <https://alerts.in.ua> site and set it as a desktop background.

Support:

- [x] KDE Plasma (Linux)
- [x] macOS (Somona)
- [x] Windows

Required libraries:

- To build this script, a requirement is to have a working version of Crystal already installed.
- A requirement is to have a working `chromedriver` or `geckodriver`.
- You will also need `qdbus` on KDE Plasma.

```
$ air_alert_map_ua_wallpaper --help
NAME
    air_alert_map_ua_wallpaper - a CLI tool for setting the Air Raid Alert Map of Ukraine as a desktop background

VERSION
    0.1.0

SYNOPSIS
    air_alert_map_ua_wallpaper [arguments]

ARGUMENTS
    -b, --browser=NAME               browser: chrome|firefox (default: chrome)
    -w, --width=PIXELS               specify a desired width in pixels (default: 2560)
    -h, --height=PIXELS              specify a desired height in pixels (default: 1440)
    -l, --language=NAME              language ua|en|de|pl|ja (default: ua)
    --light                          set light wallpaper
    -p, --preset=NAME                preset default|contrast|vadym|st|black (default: default)
    -m, --map=NAME                   map dynamic|super|vbasic|hex (default: dynamic)
    --hide-date                      hide date
    --help                           print this help
    -v, --version                    display the version and exit
```

## Install

- Clone this repository `git@github.com:mamantoha/air_alert_map_ua_wallpaper.git && cd air_alert_map_ua_wallpaper`
- Build with `shards build --release`
- Run with `./bin/air_alert_map_ua_wallpaper` or move it to any directory in `$PATH`

## Usage

Set the wallpaper on macOS:

```
air_alert_map_ua_wallpaper -t macos -w 3456 -h 2234
```

### Linux

To change background every 5 minutes the following command:

```
crontab -e
```

and add the following to the opened file:

```
*/5 * * * * env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus ~/bin/air_alert_map_ua_wallpaper
```

### macOS

Create a plist file called `com.example.air_alert_map_ua_wallpaper.plist` in the `~/Library/LaunchAgents directory`.

Add the following content to the plist file `~/Library/LaunchAgents/com.example.air_alert_map_ua_wallpaper.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.air_alert_map_ua_wallpaper</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>
        export PATH=$PATH:/opt/homebrew/bin
        while true; do ~/bin/air_alert_map_ua_wallpaper -t macos -w 3456 -h 2234; sleep 300; done
        </string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/air_alert_map_ua_wallpaper.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/air_alert_map_ua_wallpaper.log</string>
</dict>
</plist>
```
Load the launch agent into your current session using launchctl:

```
launchctl load ~/Library/LaunchAgents/com.example.air_alert_map_ua_wallpaper.plist
```

Now, the script should run every 5 minutes within user's active session.

To check the status of a launch agent:

```
launchctl list | grep com.example.air_alert_map_ua_wallpaper
```

## Contributing

1. Fork it (<https://github.com/mamantoha/air_alert_map_ua_wallpaper/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anton Maminov](https://github.com/mamantoha) - creator and maintainer
