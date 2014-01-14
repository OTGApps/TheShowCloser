class QuickLookupScreen < PM::TableScreen
  searchable
  title "Quick Lookup"

  def on_load
    set_nav_bar_button :right, system_item: :stop, action: :close
    @data ||= [{
      title: 'Loading...',
      selection_style: UITableViewCellSelectionStyleNone
    }]
  end

  def on_appear
    cells
  end

  def table_data
  [{
    title: nil,
    cells: @data
  }]
  end

  def cells
    @data = JeweleryData.file_data['database'].sort_by { |j| j['name'] }.collect do |j|
      {
        title: j['name'],
        subtitle: "Item: #{j['item']}, $#{j['price'].to_i}#{page_number(j)}",
        cell_style: UITableViewCellStyleSubtitle,
        selection_style: UITableViewCellSelectionStyleNone
      }
    end
    update_table_data
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

end
