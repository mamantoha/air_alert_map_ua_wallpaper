module AirAlertMapUaWallpaper
  class Browser
    enum Lang
      Uk
      En
    end

    @session : Selenium::Session

    def initialize(driver_path = "/usr/bin/chromedriver", width = 2560, height = 1440)
      service = Selenium::Service.chrome(driver_path: driver_path)
      driver = Selenium::Driver.for(:chrome, service: service)
      capabilities = Selenium::Chrome::Capabilities.new
      capabilities.chrome_options.args = ["no-sandbox", "headless", "disable-gpu"]

      @session = driver.create_session(capabilities)
      @session.window_manager.resize_window(width, height)
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

      wait = Selenium::Helpers::Wait.new(timeout: 5.seconds, interval: 1.second)
      wait.until { @session.find_element(:css, "#map svg") }

      element = @session.find_element(:css, "#map")

      document_manager = @session.document_manager

      unless light
        # Switch to dark theme
        document_manager.execute_script("document.documentElement.classList.toggle('light')")
      end

      # Hide "alerts.in.ua" text from the map
      document_manager.execute_script("document.querySelector('#map text.map-attr').style.display = 'none'")

      # Adjust `.credits` section
      document_manager.execute_script("document.getElementsByClassName('credits')[0].style.setProperty('bottom', '7%')")
      document_manager.execute_script("document.getElementsByClassName('credits')[0].style.setProperty('font-size', '1.5vw')")

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
