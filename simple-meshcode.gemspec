
Gem::Specification::new do |s|
  version = "1.0.0"

  files = Dir.glob("**/*") - [ 
                               Dir.glob("simple-meshcode-*.gem"), 
                             ].flatten

  s.platform    = Gem::Platform::RUBY
  s.name        = "simple-meshcode"
  s.summary     = "Japan Regional Meshcode"
  s.description = <<-HERE
    Japan Regional Meshcode
  HERE
  s.version     = version
  s.author      = "Hiroki Motoyoshi"
  s.email       = ""
  s.homepage    = 'https://github.com/himotoyoshi/simple-meshcode'
  s.files       = files
  s.extensions  = [ "ext/extconf.rb" ]
  s.required_ruby_version = ">= 1.8.1"
end
