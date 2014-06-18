class HalfPriceScreen < MasterJewelryScreen
  searchable
  longpressable
  title "Half Price Selections"
  tab_bar_item icon: "tab_jewelry", title: "1/2 Price"

  def on_load
    super
    set_nav_bar_button :right, title: "Clear All", action: :clear_all_halfprice, system_item: :trash
  end

  def build_cell(data)
    build_halfprice_cell(data)
  end
end
