class HalfPriceScreen < MasterJewelryScreen
  searchable
  longpressable
  title "Half Price Selections"
  tab_bar_item icon: "tab_jewelry", title: "1/2 Price"

  def on_load
    super
    set_nav_bar_button :right, title: "Clear All", action: :clear_all_halfprice, system_item: :trash
  end

  def build_cell(data)
    build_halfprice_cell(data)
  end

  def clear_all_halfprice
    BW::UIAlertView.new({
      title: 'Clear all half price items?',
      message: 'Are you sure you want to clear all half price hostess selections?',
      buttons: ['No', 'Yes'],
      cancel_button_index: 0
    }) do |alert|
      unless alert.clicked_button.cancel?
        Hostesses.shared_hostess.current_hostess.clear_halfprice
      end
    end.show
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
