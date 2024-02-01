require "../ext/lib_win_32"

module AirAlertMapUaWallpaper
  module ScreenResolution
    extend self

    {% if flag?(:linux) %}
      def get_screen_resolution
        get_kde_screen_resolution
      end

      def get_kde_screen_resolution
        output = `qdbus org.kde.KWin /KWin org.kde.KWin.supportInformation`

        geometry_regex = /\n+Geometry: \d+,\d+,(\d+)x(\d+)\n/
        scale_regex = /\nScale: (\d+(?:\.\d+)?)\n/

        geometry_match = geometry_regex.match(output)
        scale_match = scale_regex.match(output)

        if geometry_match && scale_match
          width = geometry_match[1].to_i * scale_match[1].to_f
          height = geometry_match[2].to_i * scale_match[1].to_f

          {width: width.to_i, height: height.to_i}
        else
          nil
        end
      end
    {% end %}

    {% if flag?(:darwin) %}
      def get_screen_resolution
        path = "/Library/Preferences/com.apple.windowserver.displays.plist"

        result = Bplist::Parser.parse(path)

        info = result.as_h.dig("DisplayAnyUserSets", "Configs").as_a[0].as_h["DisplayConfig"].as_a[0].as_h["CurrentInfo"].as_h

        width = info["Wide"].as_f.to_i * info["Scale"].as_f.to_i
        height = info["High"].as_f.to_i * info["Scale"].as_f.to_i

        {width: width, height: height}
      end
    {% end %}

    {% if flag?(:win32) %}
      def get_screen_resolution
        width = LibWin32.GetSystemMetrics(LibWin32::SYSTEM_METRICS_INDEX::SM_CXSCREEN)
        height = LibWin32.GetSystemMetrics(LibWin32::SYSTEM_METRICS_INDEX::SM_CYSCREEN)

        {width: width, height: height}
      end
    {% end %}
  end
end
