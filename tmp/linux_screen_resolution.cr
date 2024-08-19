resolution = ""

Dir.glob("/sys/class/drm/*/modes", follow_symlinks: true).each do |dev|
  single_resolution = File.open(dev) { |file| file.gets_to_end.split("\n").first }

  unless single_resolution.nil? || single_resolution.empty?
    p! dev
    resolution = "#{single_resolution}, #{resolution}"
  end
end

p! resolution
# Remove the trailing comma and space from the resolution string
resolution = resolution.chomp(", ")

width, height = resolution.split('x', 2).map(&.to_i)

result = {width: width, height: height}

puts result
