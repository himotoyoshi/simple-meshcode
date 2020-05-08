require 'simple-meshcode'
require 'rspec-power_assert'

describe "Meshcode" do 

  example 'meshcode' do 

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

  example 'meshpoint' do 

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

  example 'meshlevel' do 

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