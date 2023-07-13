module AirAlertMapUaWallpaper
  class Browser
    enum Lang
      Uk
      En
      Pl
    end

    enum Type
      Chrome
      Firefox
    end

    # dynamic | dynamic | Швидка
    # full    | false   | Класична
    # fast    | super   | Спрощена
    #         | vbasic  | Схематична
    #         | hex     | Гексагональна мапа
    # ascii   |         | ASCII мапа (don't use)
    LITE_MAPS = ["dynamic", "super", "vbasic", "hex"]

    @driver : Selenium::Driver
    @session : Selenium::Session

    def initialize(type : Type, driver_path : String, width = 2560, height = 1440)
      @driver, @session =
        case type
        in .firefox?
          create_firefox_session(driver_path)
        in .chrome?
          create_chrome_session(driver_path)
        end

      @session.window_manager.resize_window(width, height)
    end

    def create_chrome_session(driver_path : String) : {Selenium::Driver, Selenium::Session}
      service = Selenium::Service.chrome(driver_path: driver_path)
      driver = Selenium::Driver.for(:chrome, service: service)
      capabilities = Selenium::Chrome::Capabilities.new
      capabilities.chrome_options.args = ["no-sandbox", "headless", "disable-gpu"]

      session = driver.create_session(capabilities)
      {driver, session}
    end

    def create_firefox_session(driver_path : String) : {Selenium::Driver, Selenium::Session}
      # Unhandled exception: session not created: Failed to start browser /snap/firefox/current/firefox.launcher: no such file or directory (Selenium::Error)
      #
      # ```
      # sudo mkdir -p /snap/firefox/current
      # sudo ln -s /usr/bin/firefox /snap/firefox/current/firefox.launcher
      # ```
      service = Selenium::Service.firefox(driver_path: driver_path)
      driver = Selenium::Driver.for(:firefox, service: service)
      capabilities = Selenium::Firefox::Capabilities.new
      capabilities.firefox_options.args = ["-headless"]

      session = driver.create_session(capabilities)

      {driver, session}
    end

    def take_screenshot(
      language : Lang = Lang::Uk,
      light : Bool = false,
      preset : String = "default-preset",
      map : String? = nil
    ) : File
      lite_map = map.in?(LITE_MAPS) ? "\"#{map}\"" : false

      map_url =
        case language
        in Lang::Uk
          "https://alerts.in.ua?minimal&disableInteractiveMap&showWarnings"
        in Lang::En
          "https://alerts.in.ua/en?minimal&disableInteractiveMap&showWarnings"
        in Lang::Pl
          "https://alerts.in.ua/pl?minimal&disableInteractiveMap&showWarnings"
        end

      map_url = map_url + "&full" unless lite_map

      @session.navigate_to(map_url)
      document_manager = @session.document_manager

      local_storage_manager = @session.local_storage_manager
      local_storage_manager.item("liteMap", "#{lite_map}") if lite_map
      local_storage_manager.item("showRivers", "true")
      local_storage_manager.item("showNeighbourRegions", "true")
      local_storage_manager.item("showRaionBorders", "true")
      local_storage_manager.item("showUnofficialArtillery", "true")

      @session.navigation_manager.refresh

      # wait for console.log("loaded map") to be called
      document_manager.execute_async_script(
        <<-JS
        var callback = arguments[0];
        console.log = function(message) {
          if(message === "loaded map")
            callback();
        };
        JS
      )

      wait = Selenium::Helpers::Wait.new(timeout: 5.seconds, interval: 1.second)
      wait.until { @session.find_element(:css, "#map svg") }

      element = @session.find_element(:css, "#map")

      unless light
        # Switch to dark theme
        document_manager.execute_script(
          <<-JS
          if (document.documentElement.classList.contains('light')) {
            document.documentElement.classList.remove('light');
          }
          JS
        )
      end

      document_manager.execute_script("document.documentElement.classList.add('#{preset}')")

      # Hide "alerts.in.ua" text from the map
      document_manager.execute_script("document.querySelector('#map text.map-attr').style.display = 'none'")
      document_manager.execute_script("document.querySelector('#map text.map-attr-time').style.display = 'none'")

      # Adjust `.credits` section
      document_manager.execute_script("document.querySelector('.screen.map .credits').style.setProperty('top', 'initial')")
      document_manager.execute_script("document.querySelector('.screen.map .credits').style.setProperty('bottom', '7%')")
      document_manager.execute_script("document.querySelector('.screen.map .credits').style.setProperty('font-size', '1.5vw')")

      sleep 1.second

      tempfile = File.tempfile("alers_wallpaper", ".png")

      element.screenshot(tempfile.path)

      tempfile
    ensure
      @session.delete
      @driver.stop
    end

    def take_screenshot(
      language : String,
      light : Bool = false,
      preset : String = "default-preset",
      map : String? = nil
    ) : File
      language =
        case language
        when "ua"
          Lang::Uk
        when "en"
          Lang::En
        when "pl"
          Lang::Pl
        else
          Lang::Uk
        end

      take_screenshot(language, light, preset, map)
    end
  end
end
