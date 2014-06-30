class JewelryDownloader

  def check(alert = false)
    ap "Checking for Jewelry DB update for Jeweler Number: #{App::Persistence['jeweler_number']}"

    JewelryAPI.version_info do |json_data, error|
      if error.nil?
        decide(json_data, alert)
      else
        NSLog "Error retrieving data from the #{App.name} server."
      end
    end
  end

  def decide(version, alert)
    return if !version.is_a?(Hash)

    equal = eql_to?(version)
    if alert == true && equal
      BW::UIAlertView.new({
        title: 'Up To Date!',
        message: 'You have the most recent catalog data on your device.',
        buttons: ['OK']
      }).show
      return
    elsif equal
      return
    end

    if version['free_update']
      free_upgrade
    else
      @version = version
      paid_upgrade
    end

  end

  def paid_upgrade
    ap 'starting paid upgrade'
    BW::UIAlertView.new({
      title: 'Catalog Update Available',
      message: 'There is a PAID catalog update available.',
      buttons: ['Cancel', 'Purchase'],
      cancel_button_index: 0
    }) do |alert|
      if alert.clicked_button.cancel?
        ap 'Canceled'
      else
        purchase_upgrade
      end
    end.show
  end

  def purchase_upgrade
    Motion::Blitz.show('Purchasing Catalog Update', :gradient)

    @product = Vendor::Product.new(:id => @version['major'])
    @product.purchase do |product|
      p "Purchase successful: #{product.success}"
      p "Purchase transaction: #{product.transaction}"

      if product.success
        Motion::Blitz.show('Thank you for your purchase. Downloading catalog update.', :gradient)
        download_and_save
      else
        Motion::Blitz.error('Transaction Cancelled.', :gradient)
      end
    end
  end

  def free_upgrade
    Motion::Blitz.show('Downloading FREE Catalog Update', :gradient)
    download_and_save
  end

  def download_and_save
    JewelryAPI.get_jewelry do |json_text, error|
      if error.nil?
        File.open(JewelryData.file_location, 'w') { |file| file.write(json_text) }
        done_downloading
      else
        Motion::Blitz.error('Download failed. Please try again later.')
        NSLog "Error retrieving data from the #{App.name} server."
      end
    end
  end

  private
  def done_downloading
    ap 'Done Downloading'
    ap JewelryData.file_data['db']
    App::Persistence['db_version'] = JewelryData.file_data['db']
    Motion::Blitz.success('All done!')
  end

  def current_version
    App::Persistence['db_version']
  end

  def eql_to?(version)
    return false if current_version.nil?
    (current_version['major'] == version['major']) && (current_version['minor'] == version['minor'])
  end

end
