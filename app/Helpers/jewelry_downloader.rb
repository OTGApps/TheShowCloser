class JewelryDownloader

  def initialize
    @jn = App::Persistence['jeweler_number']
  end

  def check
    ap "Checking for Jewelry DB update for Jeweler Number: #{@jn}"

    JewelryAPI.version_info do |json_data, error|
      if error.nil?
        decide(json_data)
      else
        NSLog "Error retrieving data from the #{App.name} server."
      end
    end

  end

  def decide(version)
    return if !version.is_a?(Hash) || eql_to?(version)

    if version['free_update']
      free_upgrade
    else
      paid_upgrade
    end

  end

  def paid_upgrade
    ap 'starting paid upgrade'
  end

  def free_upgrade
    ap 'starting free upgrade'
    download_and_save
  end

  def download_and_save
    JewelryAPI.get_jewelry do |json_text, error|
      if error.nil?
        File.open(JeweleryData.file_location, 'w') { |file| file.write(json_text) }
        done_downloading
      else
        NSLog "Error retrieving data from the #{App.name} server."
      end
    end
  end


  private
  def done_downloading
    ap 'Done Downloading'
    ap JeweleryData.file_data['db']
    App::Persistence['db_version'] = JeweleryData.file_data['db']
  end

  def current_version
    App::Persistence['db_version']
  end

  def eql_to? version
    return false if current_version.nil?
    (current_version['major'] == version['major']) && (current_version['minor'] == version['minor'])
  end

end
