Pod::Spec.new do |s|
  s.name         = "PDColoredProgressview"
  s.version      = "0.0.1"
  s.summary      = "An UIProgressview subclass with support for setting a tint color instead of the boring default blue."
  s.homepage     = "https://github.com/PascalW/PDColoredProgressview"
  s.license      = 'MIT'
  s.author       = 'Pascal Widdershoven'
  s.source       = { :git => "https://github.com/PascalW/PDColoredProgressview.git", :commit => "bedc596f767ee32cf1ff1c5ff09db69231cd45b5" }
  s.platform     = :ios
  s.source_files = 'PDColoredProgressView.{h,m}', 'drawing.m'
end
