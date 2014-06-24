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
      action: :start_calculations
    },{
      system_item: :flexible_space
    }]
  end

  def start_calculations
    ap "Starting Calculations"
    open_modal GenieProcessorScreen.new(nav_bar: true)
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
    JewelryData.items(free_item_numbers).each do |wli|
      @free_data << build_free_cell(wli)
    end
    @free_data << {title: "No Selections"} if @free_data.count == 0

    @halfprice_data = []
    JewelryData.items(halfprice_item_numbers).each do |wli|
      @halfprice_data << build_halfprice_cell(wli)
    end
    @halfprice_data << {title: "No Selections"} if @halfprice_data.count == 0

    update_table_data
  end

end
