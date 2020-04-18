require "simple_meshcode"

module Meshcode
  
  DX = [
    0,
    1.0,
    0.125,
    0.0125,
    0.00625,
    0.003125,
    0.0015625
  ]

  DY = DX.map{|dx| dx/1.5 }

  def self.meshcode_and_offset (lat, lon, level)
    m = meshcode(lat, lon, level)
    lat0, lon0 = meshpoint(m, 0, 0)
    return m, (lat-lat0)/DY[level], (lon-lon0)/DX[level]
  end

  def self.meshinfo (m)
    level      = meshlevel(m)
    lat0, lon0 = meshpoint(m, 0, 0)
    lat1, lon1 = meshpoint(m, 1, 1)
    latc, lonc = meshpoint(m, 0.5, 0.5)
    return {
      "level"    => level,
      "meshcode" => m,
      "dy"       => DY[level],
      "dx"       => DX[level],
      "lat0"     => lat0,
      "lon0"     => lon0,
      "lat1"     => lat1,
      "lon1"     => lon1,
      "latc"     => latc,
      "lonc"     => lonc,
      "polygon"  => [
        [lon0, lat0],
        [lon1, lat0],
        [lon1, lat1],
        [lon0, lat1],
        [lon0, lat0],
      ]
    }
  end

end