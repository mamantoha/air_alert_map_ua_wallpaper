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

        parser.on("-t", "--target=NAME", "target platform: kde|macos|windows (default: #{config.target})") do |target|
          config.target = target
        end

        parser.on("-b", "--browser=NAME", "browser: #{AirAlertMapUaWallpaper::Browser::Type.names.map(&.downcase).join('|')} (default: #{config.browser})") do |browser|
          config.browser = browser
        end

        parser.on("-w", "--width=PIXELS", "specify a desired width in pixels (default: #{config.width})") do |width|
          config.width = width.to_i
        end

        parser.on("-h", "--height=PIXELS", "specify a desired height in pixels (default: #{config.height})") do |height|
          config.height = height.to_i
        end

        parser.on("-l", "--language=NAME", "language #{AirAlertMapUaWallpaper::Browser::LANGUAGES.join('|')} (default: #{config.language})") do |name|
          config.language = name
        end

        parser.on("--light", "set light wallpaper") do
          config.light = true
        end

        parser.on("-p", "--preset=NAME", "preset #{AirAlertMapUaWallpaper::Browser::PRESETS.join('|')} (default: #{config.preset})") do |name|
          config.preset = name
        end

        parser.on("-m", "--map=NAME", "map dynamic|super|vbasic|hex (default: #{config.map})") do |name|
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
          # release_date = {{ `date -R`.stringify.chomp }}
          release_date = "2024"

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
