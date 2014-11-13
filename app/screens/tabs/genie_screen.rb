class GenieScreen < MasterJewelryScreen
  longpressable
  title "Jewelry Genie"
  tab_bar_item item: "tab_genie", title: "Genie"

  def on_load
    super

    placeholder = [{
      title: 'Loading...',
      selection_style: UITableViewCellSelectionStyleNone
    }]
    @free_data ||= placeholder
    @halfprice_data ||= placeholder

    set_nav_bar_button :right, title: "Clear All", action: :clear_all, system_item: :trash
    set_toolbar_items [{
      system_item: :flexible_space
    },{
      title: "Calculate Best Deal",
      action: :start_calculations,
      tint_color: UIColor.whiteColor
    },{
      system_item: :flexible_space
    }]
    self.navigationController.toolbar.barTintColor = rmq.color.purple

  end

  def start_calculations
    p 'Starting Calculations'

    if ch.free_items.count > 0 || ch.halfprice_items.count > 0
      open_modal GenieProcessorScreen.new(nav_bar: true)
      # TODO - Once RMQ is fixed with modal positioning, make this modal again.
      # open_modal GenieProcessorScreen.new(nav_bar: true, presentation_style: UIModalPresentationFormSheet)
    else
      App.alert("Please Add Some Items!", {
        message: "You need to add at least two items to the wishlist before you do this."
      })
    end
  end

  def table_data
    [{
      title: "Half Price Selections",
      cells: @halfprice_data
    },{
      title: "Free Selections",
      cells: @free_data
    }]
  end

  def cells
    ch = Hostesses.shared_hostess.current_hostess

    free_item_numbers = ch.free_items.collect{ |j| j.item }
    halfprice_item_numbers = ch.halfprice_items.collect{ |j| j.item }

    @free_data = []
    JewelryData.data.items(free_item_numbers).each do |wli|
      @free_data << build_free_cell(wli)
    end
    @free_data << {title: "No Selections"} if @free_data.count == 0

    @halfprice_data = []
    JewelryData.data.items(halfprice_item_numbers).each do |wli|
      @halfprice_data << build_halfprice_cell(wli)
    end
    @halfprice_data << {title: "No Selections"} if @halfprice_data.count == 0

    update_table_data
  end

  def toggle_free(args, index_path)
    callback = lambda do |alert|
      case alert.clicked_button.index
      when 0
        ch.set_free(args[:item], 0)
      when 1
        if Brain.app_brain.h.jewelryPercentage.to_i == 20 && ch.halfprice_items.count >= 1
          App.alert("Can't add half price item!", {
            message: "Catalog shows only get one\nhalf price item."
          })
        else
          qty = ch.free_count(args[:item])
          ch.set_free(args[:item], 0)
          ch.set_halfprice(args[:item], qty)
        end
      else
        # They Cancelled
      end
      update_table_data
    end

    BW::UIAlertView.new({
      title: 'Change Item:',
      message: '(Tap and hold to change quantity)',
      buttons: ['Delete', 'Toggle to Half Price', 'Cancel'],
      on_click: callback
    }).show
  end

  def toggle_halfprice(args, index_path)
    callback = lambda do |alert|
      case alert.clicked_button.index
      when 0
        ch.set_halfprice(args[:item], 0)
      when 1
        qty = ch.halfprice_count(args[:item])
        ch.set_halfprice(args[:item], 0)
        ch.set_free(args[:item], qty)
      else
        # They Cancelled
      end
      update_table_data
    end

    BW::UIAlertView.new({
      title: 'Change Item:',
      message: '(Tap and hold to change quantity)',
      buttons: ['Delete', 'Toggle to Free', 'Cancel'],
      on_click: callback
    }).show
  end

  def ch
    Hostesses.shared_hostess.current_hostess
  end
end
