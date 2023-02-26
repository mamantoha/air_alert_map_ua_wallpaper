require "selenium"
require "./air_alert_map_ua_wallpaper/cli"
require "./air_alert_map_ua_wallpaper/browser"
require "./air_alert_map_ua_wallpaper/wallpaper"

module AirAlertMapUaWallpaper
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  NAME    = "air_alert_map_ua_wallpaper"

  extend self

  def config
    Config::INSTANCE
  end

  def run
    CLI.new

    browser = AirAlertMapUaWallpaper::Browser.new(width: config.width, height: config.height)
    tempfile = browser.take_screenshot

    wallpaper = AirAlertMapUaWallpaper::Wallpaper.new(tempfile)
    wallpaper.set!

    tempfile.delete
  end
end

AirAlertMapUaWallpaper.run
