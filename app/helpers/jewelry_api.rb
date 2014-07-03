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
    AFMotion::JSON.post(VERSION_URL, JewelryAPI.post_data) do |response|
      json = nil
      error = nil

      if response.success?
        json = response.object
      else
        error = { error: "Failed to get system version numbers" }
      end

      block.call json, error
    end
  end

  def self.get_jewelry(&block)
    AFMotion::JSON.post(JEWELRY_URL, JewelryAPI.post_data) do |response|
      json = nil
      error = nil

      if response.success?
        json = response.object
      else
        error = {error: "Could not download jewelry database at this time. Please try again later."}
      end

      block.call json, error
    end
  end

end
