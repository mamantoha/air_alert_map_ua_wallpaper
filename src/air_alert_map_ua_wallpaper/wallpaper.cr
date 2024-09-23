require "./ext/lib_win_32.cr"

module AirAlertMapUaWallpaper
  class Wallpaper
    @file : File

    def initialize(@file : File)
    end

    {% if flag?(:linux) %}
      def set_wallpaper
        set_kde_wallpaper
      end

      private def set_kde_wallpaper
        # https://invent.kde.org/plasma/plasma-workspace/-/blame/master/wallpapers/image/plasma-apply-wallpaperimage.cpp#L71
        script = <<-JS
          var allDesktops = desktops();
          for (i = 0; i < allDesktops.length; i++) {
            d = allDesktops[i];
            d.wallpaperPlugin = "org.kde.image";
            d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
            d.writeConfig("Image", "file://#{@file.path}")
          }
          JS

        command = "qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '#{script}'"

        output = IO::Memory.new
        Process.run(command, shell: true, output: output)

        sleep 2.seconds # workaround for multi-monitor
      end
    {% end %}

    {% if flag?(:darwin) %}
      def set_wallpaper
        path = "#{Path.home}/Library/Application Support/com.apple.wallpaper/Store/Index.plist"

        result = Bplist.parse(path)

        modified_result = rebuild_and_modify_bplist_any(result)

        writer = Bplist::Writer.new(modified_result.as_h)
        writer.write_to_file(path)

        Process.run("killall WallpaperAgent", shell: true)
      end

      private def rebuild_and_modify_bplist_any(value : Bplist::Any, path = [] of String) : Bplist::Any
        value = value.raw

        case value
        when Array
          # Convert each element of the array
          converted_array = value.map_with_index do |item, index|
            new_path = path + ["[#{index}]"]

            rebuild_and_modify_bplist_any(item, new_path)
          end

          Bplist::Any.new(converted_array)
        when Hash
          # Convert each key-value pair of the hash
          converted_hash = Hash(String, Bplist::Any).new
          value.each do |key, val|
            new_path = path + [key]

            converted_hash[key] = rebuild_and_modify_bplist_any(val, new_path)
          end

          Bplist::Any.new(converted_hash)
        when Bplist::Any::ValueType
          if path.last(3) == ["Files", "[0]", "relative"]
            value = "file://#{@file.path.to_s}"
          end

          Bplist::Any.new(value)
        else
          raise Bplist::Error.new("Unsupported type: #{value.class}")
        end
      end
    {% end %}

    {% if flag?(:win32) %}
      def set_wallpaper
        result = LibWin32.SystemParametersInfoA(
          LibWin32::SYSTEM_PARAMETERS_INFO_ACTION::SPI_SETDESKWALLPAPER,
          0,
          @file.path.to_unsafe.as(UInt8*),
          LibWin32::SYSTEM_PARAMETERS_INFO_UPDATE_FLAGS::SPIF_UPDATEINIFILE | LibWin32::SYSTEM_PARAMETERS_INFO_UPDATE_FLAGS::SPIF_SENDCHANGE
        )
        unless result
          raise "Failed to set wallpaper"
        end
      end
    {% end %}
  end
end
