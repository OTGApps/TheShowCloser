class JeweleryData

  def self.file_data
    BW::JSON.parse(File.read(JeweleryData.file_location))
  end

  def self.file_location
    File.join(App.documents_path, "jewelry.json")
  end

end
