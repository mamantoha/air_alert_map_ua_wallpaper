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

        parser.on("-w PIXELS", "--width=PIXELS", "specify a desired width (default: #{config.width})") do |width|
          config.width = width.to_i
        end

        parser.on("-h PIXELS", "--height=PIXELS", "specify a desired height (default: #{config.height})") do |height|
          config.height = height.to_i
        end

        parser.on("--help", "Show this help") do
          puts parser
          exit
        end

        parser.on("-v", "--version", "Print program version") do
          default_target = Crystal::DESCRIPTION.split.last
          release_date = {{ `date -R`.stringify.chomp }}

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
