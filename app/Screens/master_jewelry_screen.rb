class MasterJewelryScreen < PM::TableScreen
  searchable

  def on_load
    @data ||= [{
      title: 'Loading...',
      selection_style: UITableViewCellSelectionStyleNone
    }]
  end

  def on_appear
    cells

    @reload_observer = App.notification_center.observe 'ReloadJewelryTableNotification' do |notification|
      cells
    end
  end

  def on_disappear
    App.notification_center.unobserve @reload_observer
  end

  def table_data
    [{
      title: nil,
      cells: @data
    }]
  end

  def cells
    # TODO - mke this into sections by letter name
    @data = JewelryData.sorted.collect do |j|
      build_cell(j)
    end
    update_table_data
  end

  def build_cell(data)
    {
      title: cell_title(data),
      subtitle: cell_subtitle(data),
      cell_style: UITableViewCellStyleSubtitle,
      selection_style: UITableViewCellSelectionStyleNone
    }
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

  def build_free_cell(data)
    ch = Hostesses.shared_hostess.current_hostess

    cell_data(data).merge({
      action: :toggle_free,
      long_press_action: :show_qty_picker,
      image: ch.has_free?(data['item']) ? UIImage.cellImageWithText(ch.free_count(data['item'])) : 'normal',
    })
  end

  def build_halfprice_cell(data)
    ch = Hostesses.shared_hostess.current_hostess

    cell_data(data).merge({
      action: :toggle_halfprice,
      long_press_action: :show_qty_picker,
      image: ch.has_halfprice?(data['item']) ? UIImage.cellImageWithText(ch.halfprice_count(data['item'])) : 'normal',
    })
  end

  def cell_data(data)
    {
      title: cell_title(data),
      subtitle: cell_subtitle(data),
      cell_style: UITableViewCellStyleSubtitle,
      selection_style: UITableViewCellSelectionStyleDefault,
      arguments: {
        item: data['item']
      }
    }
  end

  def toggle_free(args)
    ch = Hostesses.shared_hostess.current_hostess

    qty = (ch.has_free?(args[:item])) ? 0 : 1
    ch.set_free(args[:item], qty)

    update_table_data
  end

  def toggle_halfprice(args)
    ch = Hostesses.shared_hostess.current_hostess

    qty = (ch.has_halfprice?(args[:item])) ? 0 : 1
    ch.set_halfprice(args[:item], qty)

    update_table_data
  end

end
