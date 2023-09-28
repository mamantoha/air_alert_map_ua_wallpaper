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
      command = "qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '#{kde_wallpaper_script}'"

      output = IO::Memory.new
      Process.run(command, shell: true, output: output)

      sleep 2 # workaround for multi-monitor
    end

    # # Doesn't work with multiple spaces
    # private def set_mac_wallpaper
    #   script = <<-OSA
    #     tell application "System Events"
    #       tell every desktop
    #         set picture to POSIX file "#{@file.path.to_s}"
    #       end tell
    #     end tell
    #     OSA
    #
    #   command = "osascript -e '#{script}'"
    #
    #   Process.run(command, shell: true)
    # end

    # Set the wallpaper on macOS
    # Taken from https://github.com/dylanaraps/pywal/blob/master/pywal/wallpaper.py#L133
    #
    # Wallpaper setting stop working in MacOS Sonoma
    # https://github.com/dylanaraps/pywal/issues/715
    private def set_mac_wallpaper
      img = @file.path.to_s
      db_file = Path.home.join("Library/Application Support/Dock/desktoppicture.db")

      DB.open "sqlite3://#{db_file}" do |db|
        # Put the image path in the database
        db.exec "insert into data values (?)", img

        # Get the index of the new entry
        new_entry = db.scalar "select max(rowid) from data"

        # Get all picture ids (monitor/space pairs)
        pictures = [] of Int32
        db.query("select rowid from pictures") do |rs|
          rs.each do
            pictures << rs.read(Int32)
          end
        end

        # Clear all existing preferences
        db.exec "delete from preferences"

        # Write all pictures to the new image
        pictures.each do |pic|
          db.exec "insert into preferences (key, data_id, picture_id) values (?, ?, ?)", 1, new_entry, pic
        end

        # Kill the dock to fix issues with cached wallpapers.
        # macOS caches wallpapers and if a wallpaper is set that shares
        # the filename with a cached wallpaper, the cached wallpaper is
        # used instead.
        Process.run("killall Dock", shell: true)
      end
    end

    private def kde_wallpaper_script
      <<-JS
        var allDesktops = desktops();
        for (i = 0; i < allDesktops.length; i++) {
          d = allDesktops[i];
          d.wallpaperPlugin = "org.kde.image";
          d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
          d.writeConfig("Image", "file://#{@file.path}")
        }
        JS
    end
  end
end
