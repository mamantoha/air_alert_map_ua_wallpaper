# air_alert_map_ua_wallpaper

A CLI tool for setting the Air Raid Alert Map of Ukraine as a desktop background

## About

This script takes a screenshot of the <https://alerts.in.ua> site and set it as a desktop background.

Currentry support only KDE Plasma.

Requires installed `crystal`, `chromedriver`, `qdbus`.

## Install

- Clone this repository `git@github.com:mamantoha/air_alert_map_ua_wallpaper.git && cd air_alert_map_ua_wallpaper`
- Build with `shards build --release`
- Run with `./bin/air_alert_map_ua_wallpaper` or move it to any directory in `$PATH`

## Usage

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
