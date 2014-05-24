class AppDefaults
  def self.set
    {
      kTaxEnabled: true,
      kTaxRate: "6.75",
      kShippingRate: "4.00",
      kTaxShipping: true,
      kLockPortraitMode: false,
      kReceiptName: "Your Favorite Jewelry Lady",
    }.each do |k, v|
      App::Persistence[k.to_s] ||= v
    end
  end
end
