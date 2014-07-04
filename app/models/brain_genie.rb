class BrainGenie < BrainMaster
  attr_accessor :h, :jewelry_combo

  def halfprice_items
    @jewelry_combo[:items].each_index do |i|
      @jewelry_combo[:items][i].qtyFree = 0
      @jewelry_combo[:items][i].qtyHalfPrice = (@jewelry_combo[:combo][i] == :half) ? 1 : 0
    end
    @jewelry_combo[:items].select{|i| i.qtyHalfPrice == 1 }
  end

  def free_items
    @jewelry_combo[:items].each_index do |i|
      @jewelry_combo[:items][i].qtyHalfPrice = 0
      @jewelry_combo[:items][i].qtyFree = (@jewelry_combo[:combo][i] == :free) ? 1 : 0
    end
    i = @jewelry_combo[:items].select{|i| i.qtyFree == 1 }
  end

  def tax_rate
    BigDecimal.new(h.taxRate.round(3) || 0.0)
  end

  def shipping_rate
    BigDecimal.new(h.shipping.round(3) || 0.0)
  end

end
