class AppDelegate < PM::Delegate
  include CDQ
  tint_color "#7B4289".to_color

  def on_load(app, options)
    cdq.setup
    set_appearance

    # 3rd Party integrations
    BW.debug = true unless App.info_plist['AppStoreRelease'] == true

    unless Device.simulator?
      # BITHockeyManagerLauncher.new.start
      app_id = App.info_plist['APP_STORE_ID']

      # Crittercism
      Crittercism.enableWithAppID("54c794aa3cf56b9e0457d86e")
      Crittercism.setAsyncBreadcrumbMode(true)
      Crittercism.setUsername("#{App::Persistence['jeweler_number']}") unless App::Persistence['jeweler_number'].nil?

      # Flurry
      NSSetUncaughtExceptionHandler("uncaughtExceptionHandler")
      Flurry.startSession((App.info_plist['AppStoreRelease'] == true ? "IRHW8V9LE2M38WJLSM6T" : "3W88Z2Q6MR87NHGDSMVV"))

      # Appirater
      Appirater.setAppId app_id
      Appirater.setDaysUntilPrompt 5
      Appirater.setUsesUntilPrompt 10
      Appirater.setTimeBeforeReminding 5
      Appirater.appLaunched true
    end

    # Set defaults for the application
    AppDefaults.set

    @menu = open MenuDrawer
    # @menu.show_left(false)
  end

  def set_appearance
    purple = "#7B4289".to_color

    UISwitch.appearance.setOnTintColor(purple)
    UIBarButtonItem.appearance.setTintColor(purple)
    UITabBar.appearance.setBarTintColor(rmq.color.white)
  end

  #Flurry exception handler
  def uncaughtExceptionHandler(exception)
    Flurry.logError("Uncaught", message:"Crash!", exception:exception)
  end

end
