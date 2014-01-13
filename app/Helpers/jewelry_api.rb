class JewelryAPI
  VERSION_URL = "https://raw.github.com/MohawkApps/TheShowCloser/master/data/version.json"
  JEWELRY_URL = "https://raw.github.com/MohawkApps/TheShowCloser/master/data/jewelry.json"

  def self.version_info(&block)
    BW::HTTP.get(VERSION_URL) do |response|
      text = nil
      error = nil

      if response.ok?
        text = BW::JSON.parse(response.body.to_s)
      else
        error = {error: "sorry"}
      end

      block.call text, error
    end
  end

  def self.get_jewelry(&block)
    BW::HTTP.get(JEWELRY_URL) do |response|
      text = nil
      error = nil

      if response.ok?
        text = response.body.to_str
      else
        error = {error: "sorry"}
      end

      block.call text, error
    end
  end

end
