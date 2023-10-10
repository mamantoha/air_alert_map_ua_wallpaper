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

    private def set_mac_wallpaper
      script = <<-OSA
        tell application "System Events"
          tell every desktop
            set picture to POSIX file "#{@file.path.to_s}"
          end tell
        end tell
        OSA

      command = "osascript -e '#{script}'"

      Process.run(command, shell: true)

      # Check `samples/wallpaper_schow_on_all_spaces.applescript` for more info
      script = <<-OSA
        tell application id "com.apple.systempreferences"
          reveal pane id "com.apple.Wallpaper-Settings.extension"
        end tell

        delay 1

        tell application "System Events"
          tell process "System Settings"
            set checkboxState to value of checkbox "Show on all Spaces" of group 2 of scroll area 1 of group 1 of group 2 of splitter group 1 of group 1 of window "Wallpaper"

            if checkboxState is 0 then
              click checkbox "Show on all Spaces" of group 2 of scroll area 1 of group 1 of group 2 of splitter group 1 of group 1 of window "Wallpaper"
            end if
          end tell
        end tell

        tell application "System Settings" to quit
      OSA

      command = "osascript -e '#{script}'"

      Process.run(command, shell: true)
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
