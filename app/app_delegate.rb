class AppDelegate < PM::Delegate
  include MotionDataWrapper::Delegate

  tint_color "#7B4289".to_color

  def on_load(app, options)
    # 3rd Party integrations
    unless Device.simulator?
      app_id = App.info_plist['APP_STORE_ID']

      # Flurry
      NSSetUncaughtExceptionHandler("uncaughtExceptionHandler")
      Flurry.startSession("3W88Z2Q6MR87NHGDSMVV")

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

    open_slide_menu QuickLookupScreen.new(nav_bar: true), left: hostess_screen
    slide_menu.anchorRightRevealAmount = Device.screen.width
    slide_menu.show_right(false)

    # @nav_stack = open hostess_screen

  end

  #Flurry exception handler
  def uncaughtExceptionHandler(exception)
    Flurry.logError("Uncaught", message:"Crash!", exception:exception)
  end

  def applicationWillEnterForeground(application)
    Appirater.appEnteredForeground true unless Device.simulator?
  end

end
