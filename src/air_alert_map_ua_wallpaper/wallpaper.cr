module AirAlertMapUaWallpaper
  class Wallpaper
    @file : File

    def initialize(@file : File)
    end

    def set!
      command = "qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '#{set_wallpaper_script}'"

      output = IO::Memory.new
      result = Process.run(command, shell: true, output: output)

      sleep 2 # workaround for multi-monitor
    end

    private def set_wallpaper_script
      <<-JS
        var allDesktops = desktops();
        for (i=0; i < allDesktops.length; i++) {
          d = allDesktops[i];
          d.wallpaperPlugin = "org.kde.image";
          d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
          d.writeConfig("Image", "file://#{Path[@file.path].expand}")
        }
        JS
    end
  end
end
