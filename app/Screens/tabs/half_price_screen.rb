class HalfPriceScreen < MasterJewelryScreen
  searchable
  longpressable
  title "Half Price Selections"
  tab_bar_item item: "tab_jewelry", title: "1/2 Price"

  def on_load
    super
    set_nav_bar_button :right, title: "Clear All", action: :clear_all_halfprice, system_item: :trash
  end

  def build_cell(data)
    build_halfprice_cell(data)
  end

  def cells
    super
    self.navigationController.navigationBar.topItem.title = "1/2 Price: #{Brain.app_brain.free_left_dollars}"
  end

end
