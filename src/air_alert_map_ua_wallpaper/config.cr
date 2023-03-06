module AirAlertMapUaWallpaper
  class Config
    INSTANCE = Config.new

    property target = "kde"
    property width = 2560
    property height = 1440
    property language = "ua"
    property light = false

    def img : String
      if target == "macos"
        Path.home.join("Library/Caches/air_alert_map_ua_wallpaper.png").to_s
      else
        Path.home.join(".cache").to_s
      end
    end
  end
end
