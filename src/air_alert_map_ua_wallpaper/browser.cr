module AirAlertMapUaWallpaper
  class Browser
    enum Lang
      Uk
      En
    end

    enum Type
      Chrome
      Firefox
    end

    @session : Selenium::Session

    def initialize(type : Type, driver_path : String, width = 2560, height = 1440)
      @session =
        case type
        in .firefox?
          create_firefox_session(driver_path)
        in .chrome?
          create_chrome_session(driver_path)
        end

      @session.window_manager.resize_window(width, height)
    end

    def create_chrome_session(driver_path : String) : Selenium::Session
      service = Selenium::Service.chrome(driver_path: driver_path)
      driver = Selenium::Driver.for(:chrome, service: service)
      capabilities = Selenium::Chrome::Capabilities.new
      capabilities.chrome_options.args = ["no-sandbox", "headless"]

      driver.create_session(capabilities)
    end

    def create_firefox_session(driver_path : String) : Selenium::Session
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

      driver.create_session(capabilities)
    end

    def take_screenshot(language : Lang = Lang::Uk, light : Bool = false) : File
      map_url =
        case language
        in Lang::Uk
          "https://alerts.in.ua?minimal&disableInteractiveMap&full&showWarnings"
        in Lang::En
          "https://alerts.in.ua/en?minimal&disableInteractiveMap&full&showWarnings"
        end

      @session.navigate_to(map_url)
      document_manager = @session.document_manager

      # # wait for console.log("loaded map") to be called
      # document_manager.execute_async_script(
      #   <<-JS
      #   var callback = arguments[0];
      #   console.log = function(message) {
      #     if(message === "loaded map")
      #       callback();
      #   };
      #   JS
      # )

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

      # Hide "alerts.in.ua" text from the map
      document_manager.execute_script("document.querySelector('#map text.map-attr').style.display = 'none'")

      # Adjust `.credits` section
      document_manager.execute_script("document.getElementsByClassName('credits')[0].style.setProperty('bottom', '7%')")
      document_manager.execute_script("document.getElementsByClassName('credits')[0].style.setProperty('font-size', '1.5vw')")

      sleep 500.milliseconds

      tempfile = File.tempfile("alers_wallpaper", ".png")

      element.screenshot(tempfile.path)

      tempfile
    ensure
      @session.delete
    end

    def take_screenshot(language : String, light : Bool = false) : File
      language =
        case language
        when "ua"
          Lang::Uk
        when "en"
          Lang::En
        else
          Lang::Uk
        end

      take_screenshot(language, light)
    end
  end
end
