class QuickLookupScreen < PM::TableScreen
  searchable
  title "Quick Lookup"

  def on_load
    set_nav_bar_button :right, system_item: :stop, action: :close
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

  def table_data
  [{
    title: nil,
    cells: []
  }]
  end

end
