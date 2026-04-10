require 'simple-meshcode'
require 'rspec-power_assert'

describe "Meshcode" do

  # ----------------------------------------------------------------
  # meshcode (encode)
  # ----------------------------------------------------------------

  describe '.meshcode' do

    example 'Tokyo (35.6809, 139.7673)' do
      lon = 139.7673
      lat = 35.6809
      {
        1 => "5339",
        2 => "533946",
        3 => "53394611",
        4 => "533946113",
        5 => "5339461132",
        6 => "53394611324",
      }.each do |k, m|
        is_asserted_by {
          Meshcode.meshcode(lat, lon, k) == m
        }
      end
    end

    example 'Wakkanai (45.4150, 141.6737)' do
      lat = 45.4150
      lon = 141.6737
      is_asserted_by { Meshcode.meshcode(lat, lon, 1) == "6841" }
      is_asserted_by { Meshcode.meshcode(lat, lon, 2) == "684105" }
      is_asserted_by { Meshcode.meshcode(lat, lon, 3) == "68410593" }
    end

    example 'Naha (26.3344, 127.7671)' do
      lat = 26.3344
      lon = 127.7671
      is_asserted_by { Meshcode.meshcode(lat, lon, 1) == "3927" }
      is_asserted_by { Meshcode.meshcode(lat, lon, 2) == "392746" }
      is_asserted_by { Meshcode.meshcode(lat, lon, 3) == "39274601" }
    end

  end

  # ----------------------------------------------------------------
  # meshpoint (decode)
  # ----------------------------------------------------------------

  describe '.meshpoint' do

    example 'SW corner (default offset)' do
      {
        "5339" => [35.33333333, 139.0],
        "533946" => [35.66666667, 139.75],
        "53394611" => [35.675, 139.7625],
        "533946113" => [35.67916667, 139.7625],
        "5339461132" => [35.67916667, 139.765625],
        "53394611324" => [35.68020833, 139.7671875],
      }.each do |m, (lat, lon)|
        lat1, lon1 = Meshcode.meshpoint(m)
        is_asserted_by { lat1.round(8) == lat }
        is_asserted_by { lon1.round(8) == lon }
      end
    end

    example 'with offset (0.5, 0.5) gives center' do
      [
        "5339",
        "533946",
        "53394611",
        "533946113",
        "5339461132",
        "53394611324",
      ].each do |m|
        level = Meshcode.meshlevel(m)
        lat0, lon0 = Meshcode.meshpoint(m, 0, 0)
        lat1, lon1 = Meshcode.meshpoint(m, 1, 1)
        latc, lonc = Meshcode.meshpoint(m, 0.5, 0.5)
        is_asserted_by { (latc - (lat0 + lat1) / 2.0).abs < 1e-10 }
        is_asserted_by { (lonc - (lon0 + lon1) / 2.0).abs < 1e-10 }
      end
    end

    example 'offset (1, 1) gives NE corner of next mesh' do
      lat0, lon0 = Meshcode.meshpoint("53394611", 0, 0)
      lat1, lon1 = Meshcode.meshpoint("53394611", 1, 1)
      is_asserted_by { (lat1 - lat0).round(8) == (1.0/120).round(8) }
      is_asserted_by { (lon1 - lon0).round(8) == 0.0125 }
    end

  end

  # ----------------------------------------------------------------
  # meshlevel
  # ----------------------------------------------------------------

  describe '.meshlevel' do

    example 'returns correct level for each meshcode length' do
      {
        "5339" => 1,
        "533946" => 2,
        "53394611" => 3,
        "533946113" => 4,
        "5339461132" => 5,
        "53394611324" => 6,
      }.each do |m, lev|
        is_asserted_by { Meshcode.meshlevel(m) == lev }
      end
    end

  end

  # ----------------------------------------------------------------
  # encode → decode roundtrip
  # ----------------------------------------------------------------

  describe 'encode/decode roundtrip' do

    example 'meshpoint of encoded meshcode re-encodes to same meshcode' do
      points = [
        [35.6809, 139.7673],   # Tokyo
        [45.4150, 141.6737],   # Wakkanai
        [26.3344, 127.7671],   # Naha
        [43.0621, 141.3544],   # Sapporo
        [34.6937, 135.5023],   # Osaka
      ]
      points.each do |lat, lon|
        (1..6).each do |level|
          m = Meshcode.meshcode(lat, lon, level)
          lat0, lon0 = Meshcode.meshpoint(m, 0, 0)
          is_asserted_by { Meshcode.meshcode(lat0 + 1e-10, lon0 + 1e-10, level) == m }
        end
      end
    end

  end

  # ----------------------------------------------------------------
  # meshcode_and_offset
  # ----------------------------------------------------------------

  describe '.meshcode_and_offset' do

    example 'offset is between 0 and 1' do
      lat = 35.6809
      lon = 139.7673
      (1..6).each do |level|
        m, yo, xo = Meshcode.meshcode_and_offset(lat, lon, level)
        is_asserted_by { yo >= 0 && yo < 1 }
        is_asserted_by { xo >= 0 && xo < 1 }
      end
    end

    example 'mesh center gives offset near 0.5' do
      m = "53394611"
      latc, lonc = Meshcode.meshpoint(m, 0.5, 0.5)
      _, yo, xo = Meshcode.meshcode_and_offset(latc, lonc, 3)
      is_asserted_by { (yo - 0.5).abs < 1e-8 }
      is_asserted_by { (xo - 0.5).abs < 1e-8 }
    end

  end

  # ----------------------------------------------------------------
  # meshinfo
  # ----------------------------------------------------------------

  describe '.meshinfo' do

    example 'returns expected keys' do
      info = Meshcode.meshinfo("53394611")
      expected_keys = %w[level meshcode dy dx lat0 lon0 lat1 lon1 latc lonc polygon]
      is_asserted_by { info.keys.sort == expected_keys.sort }
    end

    example 'lat0 < latc < lat1, lon0 < lonc < lon1' do
      info = Meshcode.meshinfo("53394611")
      is_asserted_by { info["lat0"] < info["latc"] }
      is_asserted_by { info["latc"] < info["lat1"] }
      is_asserted_by { info["lon0"] < info["lonc"] }
      is_asserted_by { info["lonc"] < info["lon1"] }
    end

    example 'polygon is a closed ring of 5 points' do
      info = Meshcode.meshinfo("53394611")
      poly = info["polygon"]
      is_asserted_by { poly.length == 5 }
      is_asserted_by { poly.first == poly.last }
    end

    example 'level and meshcode match' do
      info = Meshcode.meshinfo("533946113")
      is_asserted_by { info["level"] == 4 }
      is_asserted_by { info["meshcode"] == "533946113" }
    end

  end

  # ----------------------------------------------------------------
  # validation (error cases)
  # ----------------------------------------------------------------

  describe 'validation' do

    context 'meshcode encode' do

      example 'raises on invalid level' do
        expect { Meshcode.meshcode(35.0, 139.0, 0) }.to raise_error(ArgumentError)
        expect { Meshcode.meshcode(35.0, 139.0, 7) }.to raise_error(ArgumentError)
      end

      example 'raises on negative latitude' do
        expect { Meshcode.meshcode(-1.0, 139.0, 1) }.to raise_error(ArgumentError)
      end

      example 'raises on longitude < 100' do
        expect { Meshcode.meshcode(35.0, 99.0, 1) }.to raise_error(ArgumentError)
      end

      example 'raises on longitude >= 200' do
        expect { Meshcode.meshcode(35.0, 200.0, 1) }.to raise_error(ArgumentError)
      end

      example 'raises on latitude too large (lat*1.5 >= 100)' do
        expect { Meshcode.meshcode(66.7, 139.0, 1) }.to raise_error(ArgumentError)
      end

    end

    context 'meshlevel' do

      example 'raises on invalid length' do
        expect { Meshcode.meshlevel("533") }.to raise_error(ArgumentError)
        expect { Meshcode.meshlevel("5339461") }.to raise_error(ArgumentError)
        expect { Meshcode.meshlevel("533946113241") }.to raise_error(ArgumentError)
      end

    end

    context 'meshpoint' do

      example 'raises on invalid length' do
        expect { Meshcode.meshpoint("533") }.to raise_error(ArgumentError)
      end

      example 'raises on non-digit characters' do
        expect { Meshcode.meshpoint("53a9") }.to raise_error(ArgumentError)
      end

      example 'raises on invalid level-2 digit (8 or 9)' do
        expect { Meshcode.meshpoint("533986") }.to raise_error(ArgumentError)
      end

      example 'raises on invalid level-4 code (0 or 5)' do
        expect { Meshcode.meshpoint("533946110") }.to raise_error(ArgumentError)
        expect { Meshcode.meshpoint("533946115") }.to raise_error(ArgumentError)
      end

    end

  end

  # ----------------------------------------------------------------
  # boundary values
  # ----------------------------------------------------------------

  describe 'boundary values' do

    example 'point on level-1 boundary' do
      # lat=36.0 -> lat*1.5 = 54.0 exactly
      m = Meshcode.meshcode(36.0, 140.0, 1)
      is_asserted_by { m == "5440" }
      lat, lon = Meshcode.meshpoint(m, 0, 0)
      is_asserted_by { lat == 36.0 }
      is_asserted_by { lon == 140.0 }
    end

    example 'point on level-2 boundary' do
      # lat=35.0 + 5/60 = 35.08333... (one level-2 cell above 35.0)
      lat = 35.0 + 5.0/60
      lon = 139.0 + 7.5/60
      m = Meshcode.meshcode(lat, lon, 2)
      lat0, lon0 = Meshcode.meshpoint(m, 0, 0)
      is_asserted_by { (lat0 - lat).abs < 1e-8 }
      is_asserted_by { (lon0 - lon).abs < 1e-8 }
    end

    example 'point on level-3 boundary' do
      # lat=35.0 + 30/3600 (one level-3 cell above 35.0)
      lat = 35.0 + 30.0/3600
      lon = 139.0 + 45.0/3600
      m = Meshcode.meshcode(lat, lon, 3)
      lat0, lon0 = Meshcode.meshpoint(m, 0, 0)
      is_asserted_by { (lat0 - lat).abs < 1e-8 }
      is_asserted_by { (lon0 - lon).abs < 1e-8 }
    end

    example 'minimum valid coordinates' do
      m = Meshcode.meshcode(0.001, 100.001, 1)
      is_asserted_by { m == "0000" }
    end

    example 'near maximum valid coordinates' do
      m = Meshcode.meshcode(66.0, 199.0, 1)
      is_asserted_by { m == "9999" }
    end

  end

end
