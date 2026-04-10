simple-meshcode
===============

A Ruby library to calculate Japan Standard Regional Mesh (JIS X 0410).

Supports mesh levels 1 through 6 with a C extension for fast encoding/decoding.

This library covers only a subset of JIS X 0410.
It does not support doubled (2-bai) mesh, quintupled (5-bai) mesh,
or other extended mesh types defined in the standard.

Installation
------------

    gem install simple-meshcode

Or build from source:

    cd ext && ruby extconf.rb && make && cd ..

Usage
-----

```ruby
require 'simple-meshcode'
```

API
---

### Meshcode.meshcode(lat, lon, level) -> String

Encodes latitude/longitude to a meshcode string.

- `lat` (Numeric) -- latitude in degrees
- `lon` (Numeric) -- longitude in degrees (100..200)
- `level` (Integer) -- mesh level 1..6

```ruby
Meshcode.meshcode(35.6809, 139.7673, 1)  #=> "5339"
Meshcode.meshcode(35.6809, 139.7673, 3)  #=> "53394611"
```

### Meshcode.meshpoint(meshcode, yoffset=0, xoffset=0) -> [lat, lon]

Decodes a meshcode to latitude/longitude. Offsets (0.0 to 1.0) specify position within the mesh cell (0,0 = SW corner, 1,1 = NE corner).

- `meshcode` (String) -- meshcode string
- `yoffset` (Numeric) -- latitude offset (default: 0)
- `xoffset` (Numeric) -- longitude offset (default: 0)

```ruby
Meshcode.meshpoint("53394611")           #=> [35.675, 139.7625]
Meshcode.meshpoint("53394611", 0.5, 0.5) #=> [35.67916667, 139.76875]
```

### Meshcode.meshlevel(meshcode) -> Integer

Returns the mesh level inferred from the meshcode length.

```ruby
Meshcode.meshlevel("5339")        #=> 1
Meshcode.meshlevel("53394611324") #=> 6
```

### Meshcode.meshcode_and_offset(lat, lon, level) -> [meshcode, yoffset, xoffset]

Encodes to a meshcode and returns the offset (0.0 to 1.0) within the mesh cell.

```ruby
Meshcode.meshcode_and_offset(35.6809, 139.7673, 3)
#=> ["53394611", 0.708..., 0.384...]
```

### Meshcode.meshinfo(meshcode) -> Hash

Returns a hash containing mesh metadata.

```ruby
Meshcode.meshinfo("53394611")
#=> {
#     "level"    => 3,
#     "meshcode" => "53394611",
#     "dy"       => 0.00833...,
#     "dx"       => 0.0125,
#     "lat0"     => 35.675,
#     "lon0"     => 139.7625,
#     "lat1"     => 35.68333...,
#     "lon1"     => 139.775,
#     "latc"     => 35.67916...,
#     "lonc"     => 139.76875,
#     "polygon"  => [[139.7625, 35.675], ...]
#   }
```

Mesh Levels
-----------

| Level | Name | Lat span | Lon span | Code digits |
|-------|------|----------|----------|-------------|
| 1 | Primary area partition | 40' | 1 deg | 4 |
| 2 | Secondary area partition | 5' | 7'30" | 6 |
| 3 | Standard area partition | 30" | 45" | 8 |
| 4 | Half partition | 15" | 22.5" | 9 |
| 5 | Quarter partition | 7.5" | 11.25" | 10 |
| 6 | Eighth partition | 3.75" | 5.625" | 11 |

License
-------

MIT
