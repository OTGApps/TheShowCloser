class MenuDrawer < PM::Menu::Drawer

  def setup

    tab_bar = ProMotion::TabBarController.new(
      UINavigationController.alloc.initWithRootViewController(HomeShowScreen.alloc.init),
      FreeScreen.new(nav_bar:true),
      HalfPriceScreen.new(nav_bar:true),
      GenieScreen.new(nav_bar:true, toolbar: true),
      ReceiptScreen.new(nav_bar:true, external_links: false, scale_to_fit: true)
    )
    hostess_screen = HostessScreen.new(nav_bar:true, toolbar: true)

    self.center = hostess_screen
    self.right = tab_bar
    self.shadow = false
    self.animationVelocity = 2000.0 if Device.ipad?
    self.to_show = []
    self.to_hide = []

    set_width
  end

  def set_width
    self.max_right_width = Device.screen.width
  end

end
