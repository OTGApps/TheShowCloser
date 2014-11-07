# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  app.name = 'ShowCloser'
  app.deployment_target = "7.0"
  app.device_family = [:iphone, :ipad]
  app.interface_orientations = [:portrait, :portrait_upside_down, :landscape_left, :landscape_right]
  app.version = (`git rev-list HEAD --count`.strip.to_i).to_s
  app.short_version = '3.0.4'
  app.icons = Dir.glob("resources/Icon*.png").map{|icon| icon.split("/").last}
  app.seed_id = 'DW9QQZR4ZL'
  app.info_plist['FULL_APP_NAME'] = 'Show Closer'
  app.info_plist['APP_STORE_ID'] = 483940964
  app.info_plist['TestingMode'] = true if ENV['RUBYMOTION_TESTER'] == 'true'

  app.entitlements['get-task-allow'] = true
  app.codesign_certificate = "iPhone Developer: Mark Rickert (YA2VZGDX4S)"

  app.pods do
    pod 'FlurrySDK'
    pod 'Appirater'
    pod 'ActionSheetPicker-3.0', '~> 1.1.2'
  end

  app.identifier = 'com.mohawkapps.TheShowCloser'
  app.provisioning_profile = "./provisioning/development.mobileprovision"

  app.entitlements['keychain-access-groups'] = [
    app.seed_id + '.' + app.identifier
  ]
  app.entitlements['com.apple.developer.ubiquity-kvstore-identifier']     =  app.seed_id + '.' + app.identifier
  app.entitlements['com.apple.developer.ubiquity-container-identifiers']  = [app.seed_id + '.' + app.identifier]

  app.release do
    app.info_plist['AppStoreRelease'] = true
    app.entitlements['get-task-allow'] = false
    app.codesign_certificate = "iPhone Distribution: Mohawk Apps, LLC (DW9QQZR4ZL)"
    app.provisioning_profile = "./provisioning/release.mobileprovision"
  end
end
