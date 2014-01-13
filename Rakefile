# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Closer'
  app.device_family = [:iphone, :ipad]
  app.deployment_target = "7.0"
  app.device_family = [:iphone]
  app.interface_orientations = [:portrait, :portrait_upside_down]
  app.identifier = 'com.mohawkapps.TheShowCloser'
  app.version = '18'
  app.short_version = '3.0.0'
  app.icons = Dir.glob("resources/Icon*.png").map{|icon| icon.split("/").last}
  app.info_plist['FULL_APP_NAME'] = 'The Show Closer'
  app.info_plist['APP_STORE_ID'] = 483940964

  app.pods do
    pod 'FlurrySDK'
    pod 'Appirater'
    pod 'Harpy'
    pod 'TestFlightSDK'
    pod 'MRCurrencyRound'
    pod 'SVProgressHUD'
    pod 'NSDate-Extensions', :head
  end

end
