class FreeScreen < MasterJewelryScreen
  searchable
  longpressable
  title "Free Selections"
  tab_bar_item item: "tab_jewelry", title: "Free"

  def on_load
    super
    set_nav_bar_button :right, title: "Clear All", action: :clear_all_free, system_item: :trash
  end

  def build_cell(data)
    build_free_cell(data)
  end

end
