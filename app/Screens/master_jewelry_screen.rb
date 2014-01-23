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
  end

  def table_data
  [{
    title: nil,
    cells: @data
  }]
  end

  def cells
    @data = JeweleryData.file_data['database'].sort_by { |j| j['name'] }.collect do |j|
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

end
