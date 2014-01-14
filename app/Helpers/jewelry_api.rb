class JewelryAPI
  VERSION_URL = "http://theshowcloser.mohawkapps.com/3/version/"
  JEWELRY_URL = "http://theshowcloser.mohawkapps.com/3/jewelry/"

  def self.post_data
    {
      jeweler: App::Persistence['jeweler_number'],
      device: UIDevice.currentDevice.identifierForVendor.UUIDString,
      sysver: UIDevice.currentDevice.systemVersion,
      appver: App.info_plist['CFBundleShortVersionString']
    }
  end

  def self.version_info(&block)


    BW::HTTP.post(VERSION_URL, {payload: JewelryAPI.post_data}) do |response|
      json = nil
      error = nil

      if response.ok?
        json = BW::JSON.parse(response.body.to_str)
      else
        error = {error: "Failed to get system version numbers"}
      end
      block.call json, error
    end

  end

  def self.get_jewelry(&block)
    BW::HTTP.post(JEWELRY_URL, {payload: JewelryAPI.post_data}) do |response|
      text = nil
      error = nil

      if response.ok?
        text = response.body.to_s
      else
        error = {error: "sorry"}
      end

      block.call text, error
    end
  end

end
