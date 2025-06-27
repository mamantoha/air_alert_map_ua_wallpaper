require "option_parser"
require "./config"

module AirAlertMapUaWallpaper
  class CLI
    property config

    def initialize
      @config = AirAlertMapUaWallpaper.config

      parse
    end

    private def parse
      option_parser = OptionParser.parse do |parser|
        parser.banner = <<-BANNER
          NAME
              #{AirAlertMapUaWallpaper::NAME} - a CLI tool for setting the Air Raid Alert Map of Ukraine as a desktop background

          VERSION
              #{AirAlertMapUaWallpaper::VERSION}

          SYNOPSIS
              #{AirAlertMapUaWallpaper::NAME} [arguments]

          ARGUMENTS
          BANNER

        parser.on("-b", "--browser=NAME", "browser: #{AirAlertMapUaWallpaper::Browser::Type.names.map(&.downcase).join('|')} (default: #{config.browser})") do |browser|
          config.browser = browser
        end

        parser.on("-w", "--width=PIXELS", "specify a desired width in pixels (default: #{config.width})") do |width|
          config.width = width.to_i
          config.default_resolution = false
        end

        parser.on("-h", "--height=PIXELS", "specify a desired height in pixels (default: #{config.height})") do |height|
          config.height = height.to_i
          config.default_resolution = false
        end

        parser.on("-l", "--language=NAME", "language #{AirAlertMapUaWallpaper::LANGUAGES.join('|')} (default: #{config.language})") do |name|
          config.language = name
        end

        parser.on("--light", "set light wallpaper") do
          config.light = true
        end

        parser.on("-p", "--preset=NAME", "preset #{AirAlertMapUaWallpaper::PRESETS.join('|')} (default: #{config.preset})") do |name|
          config.preset = name
        end

        parser.on("-m", "--map=NAME", "map #{AirAlertMapUaWallpaper::LITE_MAPS.join('|')} (default: #{config.map})") do |name|
          config.map = name
        end

        parser.on("--hide-date", "hide date") do
          config.hide_date = true
        end

        parser.on("--help", "print this help") do
          puts parser
          exit
        end

        parser.on("-v", "--version", "display the version and exit") do
          default_target = Crystal::DESCRIPTION.split.last

          release_date =
            {% if flag?(:win32) %}
              {{ `powershell -Command "Get-Date -Format 'R'"`.stringify.chomp }}
            {% else %}
              {{ `date -R`.stringify.chomp }}
            {% end %}

          puts "#{AirAlertMapUaWallpaper::NAME} #{AirAlertMapUaWallpaper::VERSION} (#{default_target}) crystal/#{Crystal::VERSION}"
          puts "Release-Date: #{Time.parse_rfc2822(release_date).to_s("%Y-%m-%d")}"

          exit
        end

        parser.invalid_option do |flag|
          STDERR.puts "ERROR: #{flag} is not a valid option"
          STDERR.puts parser
          exit(1)
        end

        parser.missing_option do |flag|
          STDERR.puts "ERROR: missing option for #{flag}"
          STDERR.puts parser
          exit(1)
        end
      end

      option_parser.parse
    end
  end
end
