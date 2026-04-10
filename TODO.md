TODO
====

## MeshLevel 定数クラスの導入

現在 level は整数 1〜6 で指定しているが、JIS X 0410 の名称と対応する
定数オブジェクトを導入する構想がある。

```ruby
Meshcode::THIRD.encode(35.6809, 139.7673)  #=> "53394611"
Meshcode::THIRD.to_i                        #=> 3
```

定数一覧:

- `FIRST` (1) — 1次地域区画
- `SECOND` (2) — 2次地域区画
- `THIRD` (3) — 基準地域メッシュ
- `FOURTH_HALF` (4) — 2分の1地域メッシュ
- `FOURTH_QUARTER` (5) — 4分の1地域メッシュ
- `FOURTH_EIGHTH` (6) — 8分の1地域メッシュ

`to_int` を定義すれば既存の `Meshcode.meshcode(lat, lon, Meshcode::THIRD)` も
そのまま動く (C拡張の NUM2INT が自動変換する)。

実装イメージ:

```ruby
class MeshLevel
  attr_reader :level

  def initialize(level)
    @level = level
  end

  def to_i    = @level
  def to_int  = @level  # NUM2INT 互換

  def encode(lat, lon)
    Meshcode.meshcode(lat, lon, @level)
  end

  def decode(meshcode, yoffset = 0, xoffset = 0)
    Meshcode.meshpoint(meshcode, yoffset, xoffset)
  end
end

FIRST          = MeshLevel.new(1)
SECOND         = MeshLevel.new(2)
THIRD          = MeshLevel.new(3)
FOURTH_HALF    = MeshLevel.new(4)
FOURTH_QUARTER = MeshLevel.new(5)
FOURTH_EIGHTH  = MeshLevel.new(6)
```

## 未対応メッシュ種別

JIS X 0410 で定義されているが未対応のメッシュ:

- 5倍地域メッシュ (8桁、level 3 と同桁数)
- 2倍地域メッシュ (9桁、level 4 と同桁数)
- 10分の1地域メッシュ / 5次メッシュ (10桁、level 5 と同桁数)

桁数だけでは既存メッシュと区別できないため、別関数
(`meshcode_x2`, `meshcode_x5`, `meshcode_tenth` 等) での対応が現実的。
