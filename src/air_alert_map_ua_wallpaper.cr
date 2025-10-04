require "selenium"
require "bplist"
require "./air_alert_map_ua_wallpaper/cli"
require "./air_alert_map_ua_wallpaper/browser"
require "./air_alert_map_ua_wallpaper/wallpaper"
require "./air_alert_map_ua_wallpaper/helpers/screen_resolution"

module AirAlertMapUaWallpaper
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  NAME    = "air_alert_map_ua_wallpaper"

  PRESETS   = ["default", "contrast", "vadym", "st", "black", "night-red"]
  LANGUAGES = ["uk", "en", "de", "pl", "ja", "crh"]

  DEFAULT_PRESET   = "default"
  DEFAULT_LANGUAGE = "uk"

  extend self

  def config
    Config::INSTANCE
  end

  def run
    CLI.new

    width = height = nil

    if resolution = ScreenResolution.get_screen_resolution
      if config.default_resolution?
        width = resolution[:width]
        height = resolution[:height]
      end
    end

    width = width || config.width
    height = height || config.height

    browser =
      case config.browser
      when "chrome"
        if path = chromedriver_path
          AirAlertMapUaWallpaper::Browser.new(Browser::Type::Chrome, path, width: width, height: height)
        end
      when "firefox"
        if path = geckodriver_path
          AirAlertMapUaWallpaper::Browser.new(Browser::Type::Firefox, path, width: width, height: height)
        end
      end

    if browser
      file = browser.take_screenshot(
        language: config.language,
        light: config.light?,
        preset: config.preset,
        hide_date: config.hide_date?
      )

      wallpaper = AirAlertMapUaWallpaper::Wallpaper.new(file)
      wallpaper.set_wallpaper
    else
      puts "Please install chromedriver or geckodriver"
      exit
    end
  end

  def chromedriver_path : String?
    {% if flag?(:win32) %}
      `where.exe chromedriver`.strip.presence
    {% else %}
      `whereis chromedriver`.split(":")[1].strip.presence
    {% end %}
  end

  def geckodriver_path : String?
    {% if flag?(:win32) %}
      `where.exe geckodriver`.strip.presence
    {% else %}
      `whereis geckodriver`.split(":")[1].strip.presence
    {% end %}
  end
end

AirAlertMapUaWallpaper.run
