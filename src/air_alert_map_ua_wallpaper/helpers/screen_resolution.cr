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
    {% else %}
      def get_screen_resolution; end
    {% end %}
  end
end
