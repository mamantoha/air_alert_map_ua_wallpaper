require "selenium"
require "bplist"
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

    browser =
      case config.browser
      when "chrome"
        if path = chromedriver_path
          AirAlertMapUaWallpaper::Browser.new(Browser::Type::Chrome, path, width: config.width, height: config.height)
        end
      when "firefox"
        if path = geckodriver_path
          AirAlertMapUaWallpaper::Browser.new(Browser::Type::Firefox, path, width: config.width, height: config.height)
        end
      end

    if browser
      file = browser.take_screenshot(
        language: config.language,
        light: config.light?,
        preset: config.preset,
        map: config.map,
        hide_date: config.hide_date?
      )

      wallpaper = AirAlertMapUaWallpaper::Wallpaper.new(file, config.target)
      wallpaper.set!
    else
      puts "Please install chromedriver or geckodriver"
      exit
    end
  end

  def chromedriver_path : String?
    "C:\\Windows\\chromedriver.exe"
    # `whereis chromedriver`.split(":")[1].strip.presence
  end

  def geckodriver_path : String?
    `whereis geckodriver`.split(":")[1].strip.presence
  end
end

AirAlertMapUaWallpaper.run
