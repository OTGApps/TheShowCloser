class JewelryData

  def self.data
    Dispatch.once { @instance ||= new }
    @instance
  end

  def exists?
    File.exists?(file_location)
  end

  def file_data
    @file_data ||= BW::JSON.parse(File.read(file_location))
  end

  def file_location
    File.join(App.documents_path, "jewelry.json")
  end

  def sorted
    file_data['database'].sort_by { |j| j['name'] }
  end

  def item_data(number)
    i = file_data['database'].find{|item| item['item'] == number.to_s}

    res = {}
    i.each do |k,v|
      if k == 'item'
        res[k] = v.to_i
      elsif v.is_a?(Array)
        res[k] = v.join(', ')
      elsif v.is_a?(String) && (v == "0" || v == "1")
        res[k] = v.boolValue
      else
        res[k] = v
      end
    end
    res
  end

  def items(items)
    file_data['database'].select{ |j| items.include?(j['item'].to_i) }#.sort_by { |j| j.name }
  end
end
