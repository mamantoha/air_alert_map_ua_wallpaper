output = `dbus-send --print-reply --dest=org.kde.KWin /KWin org.kde.KWin.supportInformation`

geometry_regex = /\n+Geometry: \d+,\d+,(\d+)x(\d+)\n/
scale_regex = /\nScale: (\d+(?:\.\d+)?)\n/

# Extract Geometry
p! geometry_match = geometry_regex.match(output)
p! scale_match = scale_regex.match(output)

result =
  if geometry_match && scale_match
    width = geometry_match[1].to_i * scale_match[1].to_f
    height = geometry_match[2].to_i * scale_match[1].to_f

    {width: width.to_i, height: height.to_i}
  else
    nil
  end

p! result
