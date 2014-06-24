class FreeScreen < MasterJewelryScreen
  searchable
  longpressable
  title "Free: "
  tab_bar_item item: "tab_jewelry", title: "Free"

  def on_load
    super
    set_nav_bar_button :right, title: "Clear All", action: :clear_all_free, system_item: :trash
  end

  def build_cell(data)
    build_free_cell(data)
  end

  def cells
    super
    self.navigationController.navigationBar.topItem.title = "Free: #{Brain.app_brain.free_left_dollars}"
  end

end
