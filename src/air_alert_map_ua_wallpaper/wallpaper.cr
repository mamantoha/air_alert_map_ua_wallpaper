module AirAlertMapUaWallpaper
  class Wallpaper
    @file : File

    def initialize(@file : File, @target : String)
    end

    def set!
      case @target
      when "kde"
        set_kde_wallpaper
      when "macos"
        set_mac_wallpaper
      end
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

      sleep 2 # workaround for multi-monitor
    end

    private def set_mac_wallpaper
      path = "#{Path.home}/Library/Application Support/com.apple.wallpaper/Store/Index.plist"
      bplist = Bplist::Parser.new(path)

      result = bplist.parse

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
  end
end
