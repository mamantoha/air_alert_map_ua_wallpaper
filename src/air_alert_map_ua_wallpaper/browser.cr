module AirAlertMapUaWallpaper
  class Browser
    enum Type
      Chrome
      Firefox
    end

    @driver : Selenium::Driver
    @session : Selenium::Session

    def initialize(@type : Type, driver_path : String, width = 2560, height = 1440)
      @driver, @session =
        case @type
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
      capabilities.logging_prefs = {"browser" => "ALL"}

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
      language : String = DEFAULT_LANGUAGE,
      light : Bool = false,
      preset : String = DEFAULT_PRESET,
      map : String = DEFAULT_MAP,
      hide_date : Bool = false
    ) : File
      lite_map = LITE_MAPS.find(if_none: DEFAULT_MAP, &.==(map))
      language = LANGUAGES.find(if_none: DEFAULT_LANGUAGE, &.==(language))
      preset = PRESETS.find(if_none: DEFAULT_PRESET, &.==(preset))

      map_url =
        if language == "uk"
          "https://alerts.in.ua?minimal&disableInteractiveMap"
        else
          "https://alerts.in.ua/#{language}?minimal&disableInteractiveMap"
        end

      @session.navigate_to(map_url)
      document_manager = @session.document_manager

      local_storage_manager = @session.local_storage_manager
      local_storage_manager.item("liteMap", "\"#{lite_map}\"")

      local_storage_manager.item("preset", "\"#{preset}\"")

      if preset == "contrast"
        local_storage_manager.item("contrastMode", "true")
      end

      local_storage_manager.item("showRaionBorders", "true")

      local_storage_manager.item("showOfficialMapAlerts", "true")
      local_storage_manager.item("showLocalAlerts", "true")
      local_storage_manager.item("showThreats", "true")
      local_storage_manager.item("showAlertDurations", "true")
      local_storage_manager.item("showPotentialThreats", "true")
      local_storage_manager.item("showWarnings", "true")
      local_storage_manager.item("showUnofficialArtillery", "true")
      local_storage_manager.item("showForeignEvents", "true")

      local_storage_manager.item("showMapIcons", "true")
      local_storage_manager.item("showHromadas", "true")
      local_storage_manager.item("showNeighbourRegions", "true")
      local_storage_manager.item("showRivers", "true")
      local_storage_manager.item("showAllOccupiedRegions", "true")
      local_storage_manager.item("smartAlertGrouping", "true")

      @session.navigation_manager.refresh

      if @type.chrome?
        wait = Selenium::Helpers::Wait.new(timeout: 5.seconds, interval: 1.second)

        # wait for console.log("loaded map") to be called
        wait.until do
          @session.log("browser").any? &.message.ends_with?("\"loaded map\"")
        end
      end

      wait = Selenium::Helpers::Wait.new(timeout: 5.seconds, interval: 1.second)
      wait.until { @session.find_element(:css, "#map svg") }

      map_element = @session.find_element(:css, "#map")

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

      # Hide "alerts.in.ua" text from the map
      document_manager.execute_script("document.querySelector('#map text.map-attr').style.display = 'none'")
      document_manager.execute_script("document.querySelector('#map text.map-attr-time').style.display = 'none'")

      creadits_query = ".screen.map .credits"

      if hide_date
        credits_element = @session.find_element(:css, creadits_query)
        credits_element.click
      else
        # Adjust `.credits` section
        document_manager.execute_script("document.querySelector('#{creadits_query}').style.setProperty('top', 'initial')")
        document_manager.execute_script("document.querySelector('#{creadits_query}').style.setProperty('bottom', '7%')")
        document_manager.execute_script("document.querySelector('#{creadits_query}').style.setProperty('font-size', '1.5vw')")
      end

      sleep 1.second

      tempfile = File.tempfile("alers_wallpaper", ".png")

      map_element.screenshot(tempfile.path)

      tempfile.close

      tempfile
    ensure
      @session.delete
      @driver.stop
    end
  end
end
