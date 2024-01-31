def parse_resolution(output : String)
  output.each_line do |line|
    if line.includes?("Resolution:")
      if matches = line.match(/Resolution: (\d+) x (\d+)/)
        width = matches[1].to_i
        height = matches[2].to_i

        return {width: width, height: height}
      end
    end
  end
end

output = `system_profiler SPDisplaysDataType | grep Resolution`

resolution = parse_resolution(output)
p! resolution

# ---

require "bplist"

path = "/Library/Preferences/com.apple.windowserver.displays.plist"

result = Bplist::Parser.parse(path)

info = result.as_h.dig("DisplayAnyUserSets", "Configs").as_a[0].as_h["DisplayConfig"].as_a[0].as_h["CurrentInfo"].as_h

width = info["Wide"].as_f.to_i * info["Scale"].as_f.to_i
height = info["High"].as_f.to_i * info["Scale"].as_f.to_i

resolution = {width: width, height: height}
p! resolution
