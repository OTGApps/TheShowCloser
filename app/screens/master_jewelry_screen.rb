class MasterJewelryScreen < PM::TableScreen

  def on_load
    @table_data ||= [{
      title: nil,
      cells: [{
        title: 'Loading...',
        selection_style: UITableViewCellSelectionStyleNone
      }]
    }]
  end

  def on_appear
    cells

    @reload_observer = App.notification_center.observe 'ReloadJewelryTableNotification' do |notification|
      cells
    end

    # Tip
    if App::Persistence['shown_longpress_tip'].nil?
      App::Persistence['shown_longpress_tip'] = true
      App.alert("Quantity Tip:", {
        message: "You can tap and hold an item to change its quantity!"
      })
    end
  end

  def on_disappear
    @_sorted = nil
    App.notification_center.unobserve @reload_observer
  end

  def table_data
    @table_data
  end

  def cells(reload_table = true)
    @table_data = []
    section_titles.each do |t|
      section_data = {
        title: t,
        cells: []
      }
      cells = sorted.select{|j| j['name'][0].upcase == t}
      cells.each do |c|
        section_data[:cells] << build_cell(c)
      end
      @table_data << section_data
    end
    update_table_data if reload_table
    yield if block_given?
  end

  def section_titles
    sorted.collect{|j| j['name'][0].upcase}.uniq
  end

  def cell_title(data)
    data['name']
  end

  def cell_subtitle(data)
    "Item: #{data['item']}, $#{data['price'].to_i}#{page_number(data)}"
  end

  def page_number(item)
    p = item['pages']
    return "" unless p.is_a?(Array)

    case p.count
    when 1
      ", Page: #{p.first}"
    else
      ", Pages: #{p.join(', ')}"
    end
  end

  # Cell data

  def build_cell(data)
    cell_data(data).merge({
      selection_style: UITableViewCellSelectionStyleNone
    })
  end

  def build_free_cell(data)
    cell_data(data).merge({
      action: :toggle_free,
      long_press_action: :show_free_qty_picker,
      image: ch.has_free?(data['item']) ? image_num(ch.free_count(data['item'])) : image_normal,
    })
  end

  def build_halfprice_cell(data)
    cell_data(data).merge({
      action: :toggle_halfprice,
      long_press_action: :show_halfprice_qty_picker,
      image: ch.has_halfprice?(data['item']) ? image_num(ch.halfprice_count(data['item'])) : image_normal,
    })
  end

  def cell_data(data)
    c = {
      title: cell_title(data),
      subtitle: cell_subtitle(data),
      search_text: data['item'],
      cell_style: UITableViewCellStyleSubtitle,
      selection_style: UITableViewCellSelectionStyleDefault,
      arguments: {
        item: data['item']
      },
      # scoped: data['retired'] == 0 ? :current : :retired
    }
    c
  end

  #Toggling

  def toggle_free(args, index_path)
    toggle_item(args[:item], true, index_path)
  end

  def toggle_halfprice(args, index_path)
    toggle_item(args[:item], false, index_path)
  end

  def toggle_item(item, free, index_path)
    if free
      qty = (ch.has_free?(item)) ? 0 : 1
      ch.set_free(item, qty) do
        mp "Updating table data from a free item: #{index_path}"
        cells(false) do
          if searching?
            update_table_data
          else
            update_table_data(index_paths: index_path)
          end
        end
      end
    else
      qty = (ch.has_halfprice?(item)) ? 0 : 1
      if qty == 1 && Brain.app_brain.h.jewelryPercentage.to_i == 20 && ch.halfprice_items.count >= 1
        catalog_show_halfprice_error
      else
        ch.set_halfprice(item, qty) do
          mp "Updating table data from a half price item: #{index_path}"
          cells(false) do
            if searching?
              update_table_data
            else
              update_table_data(index_paths: index_path)
            end
          end
        end
      end
    end
  end

  # Clearing

  def clear(kind = :all)
    case kind
    when :free
      title = 'Clear all free items?'
      message = 'Are you sure you want to clear all free hostess selections?'
    when :halfprice
      title = 'Clear all half price items?'
      message = 'Are you sure you want to clear all half price hostess selections?'
    else
      title = 'Clear all items?'
      message = "Are you sure you want to clear all hostess selections?\nThis can not be undone."
    end

    BW::UIAlertView.new({
      title: title,
      message: message,
      buttons: ['No', 'Yes'],
      cancel_button_index: 0
    }) do |alert|
      unless alert.clicked_button.cancel?
        case kind
        when :free
          ch.clear_free
        when :halfprice
          ch.clear_halfprice
        else
          ch.clear_free
          ch.clear_halfprice
        end
        update_table_data
      end
    end.show
  end

  def clear_all_free
    clear(:free)
  end

  def clear_all_halfprice
    clear(:halfprice)
  end

  def clear_all
    clear(:all)
  end

  # Picker

  def show_free_qty_picker(args, index_path)
    show_qty_picker(args, true, index_path)
  end

  def show_halfprice_qty_picker(args, index_path)
    show_qty_picker(args, false, index_path)
  end

  def show_qty_picker(args, free, index_path)
    item = args[:item]

    if Device.ipad?
      cell = table_view.cellForRowAtIndexPath(index_path)
      sender = cell.imageView
    else
      sender = nil
    end

    # Get the initial index for the picker
    initial_index = 0
    if free && ch.has_free?(item)
      initial_index = ch.free_count(item)
    elsif !free && ch.has_halfprice?(item)
      initial_index = ch.halfprice_count(item)
    end

    ActionSheetStringPicker.showPickerWithTitle(
      "Select Qty",
      rows: (0..10).to_a.map{ |i| i.to_s },
      initialSelection: initial_index,
      doneBlock: -> picker, index, value {
        p "Picked Qty: #{value}"

        if free
          ch.set_free(item, value) do
            cells(false) do
              update_table_data(index_paths: index_path)
            end
          end
        else
          if Brain.app_brain.h.jewelryPercentage.to_i == 20 && ch.halfprice_items.count >= 1
            catalog_show_halfprice_error
          else
            ch.set_halfprice(item, value) do
              cells(false) do
                update_table_data(index_paths: index_path)
              end
            end
          end
        end
      },
      cancelBlock: -> picker {
        p 'Canceled the picker'
      },
      origin: sender)
  end

  def ch
    Hostesses.shared_hostess.current_hostess
  end

  def image_normal
    # mp 'Getting normal image'
    @images ||= {}
    @images[:normal] ||= UIImage.imageNamed('normal')
  end

  def image_num(num)
    # mp "Getting #{num} image"
    @images ||= {}
    @images[num.to_s.to_sym] ||= UIImage.imageNamed("num_#{num}")
  end

  # Background color for header views
  def tableView(tableView, willDisplayHeaderView:view, forSection:section)
    view.textLabel.setTextColor(UIColor.whiteColor)
    view.backgroundView.backgroundColor = rmq.color.purple
  end

  def catalog_show_halfprice_error
    App.alert("Can't add half price item!", {
      message: "Catalog shows only get one\nhalf price item."
    })
  end

  def sorted
    @_sorted ||= JewelryData.data.sorted
  end

end
