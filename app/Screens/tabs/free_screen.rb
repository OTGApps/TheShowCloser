class FreeScreen < MasterJewelryScreen
  searchable
  longpressable
  title "Free Selections"
  tab_bar_item icon: "tab_jewelry", title: "Free"

  def build_cell(data)
    {
      selection_style: UITableViewCellSelectionStyleDefault,
      action: :toggle_free,
      long_press_action: :show_qty_picker,
      image: Hostesses.shared_hostess.current_hostess.has_free?(data['item']) ? UIImage.cellImageWithText(Hostesses.shared_hostess.current_hostess.free_count(data['item'])) : 'normal',
      arguments: {
        item: data['item']
      },
    }.merge(super)
  end

  def toggle_free(args)
    ch = Hostesses.shared_hostess.current_hostess

    qty = (ch.has_free?(args[:item])) ? 0 : 1
    ch.set_free(args[:item], qty)
  end

  def show_qty_picker(args)
    initial_index = 0
    if Hostesses.shared_hostess.current_hostess.has_free?(args[:item])
      initial_index = Hostesses.shared_hostess.current_hostess.free_count(args[:item])
    end
    ap initial_index

    ActionSheetStringPicker.showPickerWithTitle(
      "Select Qty",
      rows: (0..10).to_a.map{ |i| i.to_s },
      initialSelection: initial_index,
      doneBlock: -> picker, index, value {
        ap "Picked Qty: #{value}"
        Hostesses.shared_hostess.current_hostess.set_free(args[:item], value)
        update_table_data
      },
      cancelBlock: -> picker {
        ap "Canceled the picker"
      },
      origin: self.view)
  end

end
