require "../ext/lib_win_32"

module AirAlertMapUaWallpaper
  module ScreenResolution
    extend self

    {% if flag?(:win32) %}
      def get_screen_resolution
        width = LibWin32.GetSystemMetrics(LibWin32::SYSTEM_METRICS_INDEX::SM_CXSCREEN)
        height = LibWin32.GetSystemMetrics(LibWin32::SYSTEM_METRICS_INDEX::SM_CYSCREEN)

        {width: width, height: height}
      end
    {% elsif flag?(:darwin) %}
      def get_screen_resolution
        path = "/Library/Preferences/com.apple.windowserver.displays.plist"

        result = Bplist::Parser.parse(path)

        info = result.as_h.dig("DisplayAnyUserSets", "Configs").as_a[0].as_h["DisplayConfig"].as_a[0].as_h["CurrentInfo"].as_h

        width = info["Wide"].as_f.to_i * info["Scale"].as_f.to_i
        height = info["High"].as_f.to_i * info["Scale"].as_f.to_i

        {width: width, height: height}
      end
    {% else %}
      def get_screen_resolution; end
    {% end %}
  end
end
