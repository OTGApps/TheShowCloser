class JewelryData
  def self.exists?
    File.exists?(JewelryData.file_location)
  end

  def self.file_data
    BW::JSON.parse(File.read(JewelryData.file_location))
  end

  def self.file_location
    File.join(App.documents_path, "jewelry.json")
  end

  def self.sorted
    file_data['database'].sort_by { |j| j['name'] }
  end

  def self.item_data(number)
    i = file_data['database'].find{|item| item['item'] == number.to_s}
    ap i.class
    ap i

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

  def self.items(items)
    file_data['database'].select{ |j| items.include?(j['item'].to_i) }#.sort_by { |j| j.name }
  end
end
