class QuickLookupScreen < PM::TableScreen
  searchable
  title "Quick Lookup"

  def on_load
    set_nav_bar_button :right, system_item: :stop, action: :close
  end

  def on_appear
    ap "test"
  end

  def table_data
  [{
    title: nil,
    cells: cells
  }]
  end

  def cells
    ap JeweleryData.file_data['database']

    JeweleryData.file_data['database'].sort_by { |j| j['name'] }.collect do |j|
      {
        title: j['name'],
        subtitle: "Item: #{j['item']}, $#{j['price'].to_i}#{page_number(j)}",
        cell_style: UITableViewCellStyleSubtitle,
        selection_style: UITableViewCellSelectionStyleNone
      }
    end
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
