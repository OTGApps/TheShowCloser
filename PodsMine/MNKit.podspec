Pod::Spec.new do |s|
  s.name         = "MNKit"
  s.version      = "0.0.1"
  s.summary      = "MNKit is a collection of reusable iOS components. It includes a stepper control - MNStepper - and a color picker - MNColorSelectionViewController that mimic controls Apple is using in their iWork applications."
  s.homepage     = "https://bitbucket.org/aquarius/mnkit"
  s.license      = 'MIT'
  s.source       = { :hg => "https://bitbucket.org/aquarius/mnkit", :revision => 'tip' }
  s.platform     = :ios
  s.source_files = 'Frameworks/CoreText/*.{h,m}', 'Frameworks/Foundation/Categories/*.{h,m}', 'Frameworks/Global/*.{h,m}', 'Frameworks/UIKit/*.{h,m}', 'Frameworks/UIKit/Categories/*.{h,m}'
  s.resources    = 'Frameworks/UIKit/Resources/*'
  s.requires_arc = false
  s.prefix_header_contents = "#define MNRelease(object) [object release], object=nil;"
end
