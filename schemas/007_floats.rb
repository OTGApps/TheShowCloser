  schema "007" do

    entity "Hostess" do
      string    :addtlCharge, default: 0
      string    :addtlDiscount, default: 0
      boolean   :bonus1, default: false
      boolean   :bonus2, default: false
      boolean   :bonus3, default: false
      boolean   :bonus4, default: false
      integer16 :bonusValue, default: 50
      integer16 :bonusExtra, default: 0
      datetime  :createdDate, optional: false
      string    :discount, default: 0.0
      integer16 :jewelryPercentage, default: 30
      string    :name
      boolean   :promotion304050, default: false
      string    :promotion304050Trigger40, default: 400
      string    :promotion304050Trigger50, default: 500
      string    :shipping, default: 4
      string    :showTotal, default: 0
      boolean   :taxEnabled, default: true
      string    :taxRate
      boolean   :taxShipping, default:true
      string    :notes

      has_many  :wishlist, inverse: "WishlistItem.hostesses"
    end

    entity "WishlistItem" do
      string    :catalog
      integer16 :item
      string    :name
      string    :pages
      string    :price
      integer16 :qtyFree, default: 0
      integer16 :qtyHalfPrice, default: 0
      boolean   :retired
      boolean   :stopSell
      string    :type

      belongs_to :hostesses, inverse: "Hostess.wishlist"
    end

  end
