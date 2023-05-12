module AirAlertMapUaWallpaper
  class Config
    INSTANCE = Config.new

    property target = "kde"
    property browser = "chrome"
    property width = 2560
    property height = 1440
    property language = "ua"
    property? light = false
    property preset = "default-preset"
  end
end
