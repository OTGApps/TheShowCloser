class QuickLookupScreen < MasterJewelryScreen
  searchable
  title "Quick Lookup"

  def on_load
    super
    set_nav_bar_button :right, system_item: :stop, action: :close
  end
end
