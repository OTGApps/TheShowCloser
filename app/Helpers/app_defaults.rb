class AppDefaults
  def self.set
    # defaults = NSUserDefaults.standardUserDefaults

    {
      kTaxEnabled: true,
      kTaxRate: 6.75,
      kTaxShipping: true,
      kLockPortraitMode: false,
      kReceiptName: "Your Favorite Jewelry Lady",
    }.each do |k, v|
      App::Persistence[k.to_s] ||= v
    end
  end
end
