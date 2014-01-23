class JewelryScreen < MasterJewelryScreen
  searchable
  title "Jewelry"
  tab_bar_item icon: "tab_jewelry", title: "Jewelry"

  def on_load
    super
  end

  def on_appear
    super
    ap "test"
  end

end
