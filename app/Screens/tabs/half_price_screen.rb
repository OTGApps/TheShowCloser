class HalfPriceScreen < MasterJewelryScreen
  searchable
  title "Half Price Selections"
  tab_bar_item icon: "tab_jewelry", title: "1/2 Price"

  def build_cell(data)
    {
      selection_style: UITableViewCellSelectionStyleDefault,
      action: :toggle_halfprice,
      long_press_action: :show_qty_picker,
      image: Hostesses.shared_hostess.current_hostess.has_halfprice?(data['item']) ? UIImage.cellImageWithText(Hostesses.shared_hostess.current_hostess.halfprice_count(data['item'])) : 'normal',
      arguments: {
        item: data['item']
      },
    }.merge(super)
  end

  def toggle_halfprice(args)
    ch = Hostesses.shared_hostess.current_hostess

    qty = (ch.has_halfprice?(args[:item])) ? 0 : 1
    ch.set_halfprice(args[:item], qty)
  end

  def show_qty_picker(args)
    initial_index = 0
    if Hostesses.shared_hostess.current_hostess.has_halfprice?(args[:item])
      initial_index = Hostesses.shared_hostess.current_hostess.halfprice_count(args[:item])
    end

    ActionSheetStringPicker.showPickerWithTitle(
      "Select Qty",
      rows: (0..10).to_a.map{ |i| i.to_s },
      initialSelection: initial_index,
      doneBlock: -> picker, index, value {
        ap "Picked Qty: #{value}"
        Hostesses.shared_hostess.current_hostess.set_halfprice(args[:item], value)
      },
      cancelBlock: -> picker {
        ap "Canceled the picker"
      },
      origin: self.view)
  end
end
