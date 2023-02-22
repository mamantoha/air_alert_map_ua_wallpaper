require "selenium"

# module AirAlertMapUaWallpaper
#   VERSION = "0.1.0"
# end

# This scripts takes a screenshot of https://alerts.in.ua and set it as a desktop backgroud.
# Currentry support only KDE Plasma.
# Requires installed chromedriver, qdbus.

# Build:
#
# shards build --release
# cp bin/air_alert_map_ua_wallpaper ~/bin

# Set crontab job for user:
# crontab -e
#
# ```
# */5 * * * *	env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus ~/bin/air_alert_map_ua_wallpaper
# ```

# Desktop resolution
width = 2560
height = 1440

driver_path = "/usr/bin/chromedriver"

service = Selenium::Service.chrome(driver_path: driver_path)
driver = Selenium::Driver.for(:chrome, service: service)
capabilities = Selenium::Chrome::Capabilities.new
capabilities.chrome_options.args = ["no-sandbox", "headless", "disable-gpu"]
session = driver.create_session(capabilities)

session.window_manager.resize_window(width, height)

# https://alerts.in.ua/?minimal&disableInteractiveMap
# map_url = "https://alerts.in.ua/en"
map_url = "https://alerts.in.ua"

session.navigate_to(map_url)

# TODO check if site is loaded
#
# https://github.com/matthewmcgarvey/selenium.cr/pull/25
#
# wait = Selenium::Helpers::Wait.new(timeout: 5.seconds, interval: 1.second)
# wait.until { session.find_element(:css, "#map svg") }
sleep 5.seconds

element : Selenium::Element = begin
  session.find_element(:css, "#map")
rescue e : Selenium::Error
  exit
end

document_manager = session.document_manager

# Switch to dark theme
document_manager.execute_script("document.getElementsByTagName('html')[0].classList.toggle('light')")

# Adjust `.credits` section
document_manager.execute_script("document.getElementsByClassName('credits')[0].style.setProperty('bottom', '7%')")
document_manager.execute_script("document.querySelector('.credits h2').style.display = 'none'")
document_manager.execute_script("document.getElementsByClassName('credits')[0].style.setProperty('font-size', 'xx-large')")

tempfile = File.tempfile("alers_wallpaper", ".png")

element.screenshot(tempfile.path)
session.delete

if tempfile.size.zero?
  tempfile.delete

  exit
end

# https://gist.github.com/mamantoha/c01363e5c791e8324d6248b09cf29bbb
set_wallpaper_script = <<-JS
  var allDesktops = desktops();
  print (allDesktops);
  for (i=0; i < allDesktops.length; i++) {
    d = allDesktops[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
    d.writeConfig("Image", "file://#{Path[tempfile.path].expand}")
  }
  JS

command = "qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '#{set_wallpaper_script}'"

output = IO::Memory.new
result = Process.run(command, shell: true, output: output)
sleep 2 # workaround for multi-monitor
tempfile.delete
