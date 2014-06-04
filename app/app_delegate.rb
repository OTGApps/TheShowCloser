class AppDelegate < PM::Delegate
  include CDQ
  tint_color "#7B4289".to_color

  def on_load(app, options)
    cdq.setup

    # 3rd Party integrations
    BW.debug = true unless App.info_plist['AppStoreRelease'] == true

    unless Device.simulator?
      app_id = App.info_plist['APP_STORE_ID']

      # Flurry
      NSSetUncaughtExceptionHandler("uncaughtExceptionHandler")
      Flurry.startSession((App.info_plist['AppStoreRelease'] == true ? "IRHW8V9LE2M38WJLSM6T" : "3W88Z2Q6MR87NHGDSMVV"))

      # Appirater
      Appirater.setAppId app_id
      Appirater.setDaysUntilPrompt 5
      Appirater.setUsesUntilPrompt 10
      Appirater.setTimeBeforeReminding 5
      Appirater.appLaunched true

      # Harpy
      Harpy.sharedInstance.setAppID app_id
      Harpy.sharedInstance.checkVersion
    end

    # Set defaults for the application
    AppDefaults.set

    hostess_screen = HostessScreen.new(nav_bar:true, toolbar: true)

    @tab_bar = ProMotion::TabBarController.new(
      UINavigationController.alloc.initWithRootViewController(HomeShowScreen.alloc.init),
      FreeScreen.new(nav_bar:true),
      HalfPriceScreen.new(nav_bar:true),
      GenieScreen.new(nav_bar:true),
      ReceiptScreen.new(nav_bar:true, external_links: false)
    )

    open_slide_menu @tab_bar, left: hostess_screen
    slide_menu.anchorRightRevealAmount = Device.screen.width
    slide_menu.show_right(false)

  end

  #Flurry exception handler
  def uncaughtExceptionHandler(exception)
    Flurry.logError("Uncaught", message:"Crash!", exception:exception)
  end

end
