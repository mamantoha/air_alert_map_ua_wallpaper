require "selenium"
require "sqlite3"
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

    browser = AirAlertMapUaWallpaper::Browser.new(chromedriver_path, width: config.width, height: config.height)
    file = browser.take_screenshot(language: config.language, light: config.light)

    wallpaper = AirAlertMapUaWallpaper::Wallpaper.new(file, config.target)
    wallpaper.set!
  end

  def chromedriver_path : String
    {{ `whereis chromedriver`.split(":")[1].strip }}
  end
end

AirAlertMapUaWallpaper.run
