# air_alert_map_ua_wallpaper

A CLI tool for setting the Air Raid Alert Map of Ukraine as a desktop background

![preview](preview.png)

## About

This script takes a screenshot of the <https://alerts.in.ua> site and set it as a desktop background.

Support:

- [x] KDE Plasma (Linux)
- [x] macOS

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
    -t, --target=NAME                target platform: kde|macos (default: kde)
    -b, --browser=NAME               browser: chrome|firefox (default: chrome)
    -w, --width=PIXELS               specify a desired width in pixels (default: 2560)
    -h, --height=PIXELS              specify a desired height in pixels (default: 1440)
    -l, --language=NAME              language ua|en (default: ua)
    -p, --preset=NAME                preset default-preset|contrast-preset|vadym-preset|black-preset (default: default-preset)
    -m, --map=NAME                   map dynamic|super|vbasic|hex (default: )
    --light                          set light wallpaper
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

### crontab

To change background every 5 minutes the following command:

```
crontab -e
```

and add the following to the opened file:

```
*/5 * * * * env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus ~/bin/air_alert_map_ua_wallpaper
```

## Contributing

1. Fork it (<https://github.com/mamantoha/air_alert_map_ua_wallpaper/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anton Maminov](https://github.com/mamantoha) - creator and maintainer
