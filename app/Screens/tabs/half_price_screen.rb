class HalfPriceScreen < MasterJewelryScreen
  searchable
  title "Half Price Selections"
  tab_bar_item icon: "tab_jewelry", title: "1/2 Price"

  def build_cell(data)
    {
      selection_style: UITableViewCellSelectionStyleDefault,
      action: :toggle_half,
      image: Hostesses.shared_hostess.current_hostess.has_halfprice?(data['item']) ? 'half' : 'normal',
      arguments: { item: data['item'] },
    }.merge(super)
  end

  def toggle_half(args)
    ch = Hostesses.shared_hostess.current_hostess

    if ch.has_halfprice?(args[:item])
      ch.remove_halfprice(args[:item])
    else
      ch.add_halfprice(args[:item])
    end

    update_table_data
  end

end
