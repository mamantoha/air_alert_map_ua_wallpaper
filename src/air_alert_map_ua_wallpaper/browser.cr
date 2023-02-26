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

    def take_screenshot(lang : Lang = Lang::Uk) : File
      map_url =
        case lang
        in Lang::Uk
          "https://alerts.in.ua"
        in Lang::En
          "https://alerts.in.ua/en"
        end

      @session.navigate_to(map_url)

      # TODO check if site is loaded
      #
      # https://github.com/matthewmcgarvey/selenium.cr/pull/25
      #
      # wait = Selenium::Helpers::Wait.new(timeout: 5.seconds, interval: 1.second)
      # wait.until { @session.find_element(:css, "#map svg") }
      sleep 5.seconds

      element = @session.find_element(:css, "#map")

      document_manager = @session.document_manager

      document_manager.execute_script(java_script)

      tempfile = File.tempfile("alers_wallpaper", ".png")

      element.screenshot(tempfile.path)

      @session.delete

      tempfile
    end

    def take_screenshot(language : String) : File
      language =
        case language
        when "ua"
          Lang::Uk
        when "en"
          Lang::En
        else
          Lang::Uk
        end

      take_screenshot(language)
    end

    def java_script
      <<-JS
        // Switch to dark theme
        document.getElementsByTagName('html')[0].classList.toggle('light');
        // Adjust `.credits` section
        document.getElementsByClassName('credits')[0].style.setProperty('bottom', '7%');
        document.querySelector('.credits h2').style.display = 'none';
        document.getElementsByClassName('credits')[0].style.setProperty('font-size', 'xx-large');
        JS
    end
  end
end