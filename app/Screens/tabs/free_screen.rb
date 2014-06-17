class FreeScreen < MasterJewelryScreen
  searchable
  longpressable
  title "Free Selections"
  tab_bar_item icon: "tab_jewelry", title: "Free"

  def on_load
    super
    set_nav_bar_button :right, title: "Clear All", action: :clear_all_free, system_item: :trash
  end

  def build_cell(data)
    build_free_cell(data)
  end

  def clear_all_free
    BW::UIAlertView.new({
      title: 'Clear all free items?',
      message: 'Are you sure you want to clear all free hostess selections?',
      buttons: ['No', 'Yes'],
      cancel_button_index: 0
    }) do |alert|
      unless alert.clicked_button.cancel?
        Hostesses.shared_hostess.current_hostess.clear_free
      end
    end.show
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
