class FreeScreen < MasterJewelryScreen
  searchable
  title "Free Selections"
  tab_bar_item icon: "tab_jewelry", title: "Free"

  def build_cell(data)
    {
      selection_style: UITableViewCellSelectionStyleDefault,
      action: :toggle_free,
      image: Hostesses.shared_hostess.current_hostess.has_free?(data['item']) ? 'free' : 'normal',
      arguments: { item: data['item'] },
    }.merge(super)
  end

  def toggle_free(args)
    ch = Hostesses.shared_hostess.current_hostess

    if ch.has_free?(args[:item])
      ch.remove_free(args[:item])
    else
      ch.add_free(args[:item])
    end

    update_table_data
  end

end
