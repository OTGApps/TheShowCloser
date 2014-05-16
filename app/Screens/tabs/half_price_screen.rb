class HalfPriceScreen < MasterJewelryScreen
  searchable
  title "Half Price Selections"
  tab_bar_item icon: "jewelry", title: "1/2 Price"

  def on_load
    super
  end

  def on_appear
    super
    ap "test"
  end

end
