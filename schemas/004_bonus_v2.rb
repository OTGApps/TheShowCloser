  schema "004" do

    entity "Hostess" do
      float     :addtlCharge, default: 0
      float     :addtlDiscount, default: 0
      boolean   :bonus1, default: false
      boolean   :bonus2, default: false
      boolean   :bonus3, default: false
      boolean   :bonus4, default: false
      boolean   :bonusV2_1, default: false
      boolean   :bonusV2_2, default: false
      integer16 :bonusValue, default: 25
      integer16 :bonusExtra, default: 0
      datetime  :createdDate, optional: false
      float     :discount, default: 0.0
      integer16 :jewelryPercentage, default: 0.0
      string    :name
      boolean   :promotion304050, default: false
      float     :promotion304050Trigger40, default: 400
      float     :promotion304050Trigger50, default: 500
      float     :shipping, default: 4
      float     :showTotal, default: 0
      boolean   :taxEnabled, default: true
      float     :taxRate
      boolean   :taxShipping, default:true

      has_many  :wishlist, inverse: "WishlistItem.hostesses"
    end

    entity "WishlistItem" do
      string    :catalog
      integer16 :item
      string    :name
      string    :pages
      float     :price
      integer16 :qtyFree, optional: false, default: 0
      integer16 :qtyHalfPrice, default: 0
      boolean   :retired
      boolean   :stopSell
      string    :type

      belongs_to :hostesses, inverse: "Hostess.wishlist"
    end

  end
