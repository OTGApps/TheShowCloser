Pod::Spec.new do |s|
  s.name         = "DCRoundSwitch"
  s.version      = "0.0.1"
  s.summary      = "A 'modern' replica of UISwitch."
  s.homepage     = "https://github.com/domesticcatsoftware/DCRoundSwitch"
  s.license      = 'MIT'
  s.source       = { :git => "https://github.com/domesticcatsoftware/DCRoundSwitch.git", :commit => '88fc73' }
  s.platform     = :ios
  s.source_files = 'DCRoundSwitch/*.{h,m}'
  s.requires_arc = false
end
