class JewelryDownloader

  def check(alert = false)
    mp "Checking for Jewelry DB update for Jeweler Number: #{App::Persistence['jeweler_number']}"

    JewelryAPI.version_info do |json_data, error|
      if error.nil?
        decide(BW::JSON.parse(json_data), alert)
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

    if App.info_plist['TestingMode'] == true
      free_upgrade
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
    mp 'Starting paid upgrade'
    BW::UIAlertView.new({
      title: 'Catalog Update Available',
      message: 'There is a PAID catalog update available.',
      buttons: ['Cancel', 'Purchase'],
      cancel_button_index: 0
    }) do |alert|
      if alert.clicked_button.cancel?
        mp 'Canceled'
      else
        purchase_upgrade
      end
    end.show
  end

  def purchase_upgrade
    Motion::Blitz.show('Purchasing Catalog Update', :gradient)

    NSLog "Starting purchase process."

    @iap_helper = IAPHelper.new(NSSet.setWithArray([@version['major']]))
    @iap_helper.cancelled = cancelled_transaction
    @iap_helper.success = transaction_successful
    # Verify that the product exists and can be purchased
    @iap_helper.request_product_info do |success, products|
      if success && products.is_a?(Array) && products.count == 1
        # Purchase the product
        @iap_helper.buy_product(products.first)
      else
        Motion::Blitz.error('There was a problem. Please try again later.')
      end
    end
  end

  def cancelled_transaction
    lambda {
      # TODO - Don't keep prompting if the user doesn't want to see the update.
      Motion::Blitz.error('Transaction Cancelled.')
    }
  end

  def transaction_successful
    lambda {
      Motion::Blitz.show('Thank you for your purchase. Downloading catalog update!', :gradient)
      download_and_save
    }
  end

  def free_upgrade
    Motion::Blitz.show('Downloading FREE Catalog Update', :gradient)
    download_and_save
  end

  def download_and_save
    JewelryAPI.get_jewelry do |json, error|
      if error.nil?
        File.open(JewelryData.data.file_location, 'w') { |file| file.write(json) }
        done_downloading
      else
        Motion::Blitz.error('Download failed. Please try again later.')
        NSLog "Error retrieving data from the #{App.name} server."
      end
    end
  end

  private

  def done_downloading
    mp 'Done Downloading'
    JewelryData.data.reset # Reset the cache
    App::Persistence['db_version'] = JewelryData.data.file_data['db']
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
