module AirAlertMapUaWallpaper
  class Config
    INSTANCE = Config.new

    property browser = "chrome"
    property width = 2560
    property height = 1440
    property language = "uk"
    property? light = false
    property preset = "default"
    property map = "dynamic"
    property? hide_date = false
  end
end
