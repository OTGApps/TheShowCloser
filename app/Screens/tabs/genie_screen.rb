class GenieScreen < MasterJewelryScreen
  title "Jewelry Genie"
  tab_bar_item icon: "tab_genie", title: "Genie"

  # def on_load
  #   super
  #   set_nav_bar_button :right, title: "Clear All", action: :clear_all_free, system_item: :trash
  # end

  # def build_cell(data)
  #   super.merge({
  #     selection_style: UITableViewCellSelectionStyleDefault,
  #     action: :toggle_free,
  #     long_press_action: :show_qty_picker,
  #     image: Hostesses.shared_hostess.current_hostess.has_free?(data['item']) ? UIImage.cellImageWithText(Hostesses.shared_hostess.current_hostess.free_count(data['item'])) : 'normal',
  #     arguments: {
  #       item: data['item']
  #     }
  #   })
  # end

end
