module AirAlertMapUaWallpaper
  class Config
    INSTANCE = Config.new

    property browser = "chrome"
    property width = 2560
    property height = 1440
    property? default_resolution = true
    property language = DEFAULT_LANGUAGE
    property? light = false
    property preset = DEFAULT_PRESET
    property? hide_date = false
  end
end
