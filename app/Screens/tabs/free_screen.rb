class FreeScreen < MasterJewelryScreen
  searchable
  title "Free Selections"
  tab_bar_item icon: "jewelry", title: "Free"

  def on_load
    super
  end

  def on_appear
    super
    ap "test"
  end

end
