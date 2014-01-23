class ReceiptScreen < PM::Screen
  title "Receipt"
  tab_bar_item icon: "tab_receipt", title: "Receipt"

  def on_load
    view.backgroundColor = UIColor.whiteColor

    # set_nav_bar_button :left, title: :stop, action: :close
    # set_nav_bar_button :right, system_icon: :add, action: :add_hostess
    # set_toolbar_items [{
    #     system_item: :flexible_space
    #   }, {
    #     title: "Global Settings",
    #     action: :show_global_options,
    #   }]
    # ap Hostess.destroy_all
  end

  def on_appear
    ap "test"
  end

end
