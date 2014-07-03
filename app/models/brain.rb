class Brain
  attr_accessor :tmp_jewelry_combo

  def self.app_brain
    Dispatch.once { @instance ||= new }
    @instance
  end

  def h
    Hostesses.shared_hostess.current_hostess
  end

  def tax_rate
    ((h.tax_enabled?) ? h.tax_rate : BigDecimal.new(0.0)) / 100.00
  end

  def shipping_rate
    h.shipping_rate
  end

  def shipping_total
    (h.tax_shipping?) ? shipping_rate * (tax_rate + 1) : shipping_rate
  end

  def halfprice_items
    if tmp_jewelry_combo.nil?
      h.halfprice_items
    else
      tmp_jewelry_combo[:items].each_index do |i|
        tmp_jewelry_combo[:items][i].qtyFree = 0
        tmp_jewelry_combo[:items][i].qtyHalfPrice = 0
        tmp_jewelry_combo[:items][i].qtyHalfPrice = 1 if tmp_jewelry_combo[:combo][i] == :half
      end

      tmp_jewelry_combo[:items].select{|i| i.qtyHalfPrice > 0}
    end
  end

  def half_price_total
    total = BigDecimal.new(0)
    ap "Half Price Items:"
    ap halfprice_items
    halfprice_items.each do |item|
      total = (BigDecimal.new(item.price) * item.qtyHalfPrice) + total
    end
    ap "Calculating half price total: #{total / 2}"
    total / 2
  end

  def free_items
    if tmp_jewelry_combo.nil?
      h.free_items
    else
      tmp_jewelry_combo[:items].each_index do |i|
        tmp_jewelry_combo[:items][i].qtyFree = 0
        tmp_jewelry_combo[:items][i].qtyHalfPrice = 0
        tmp_jewelry_combo[:items][i].qtyFree = 1 if tmp_jewelry_combo[:combo][i] == :free
      end

      tmp_jewelry_combo[:items].select{|i| i.qtyFree > 0}
    end
  end

  def free_total
    total = BigDecimal.new(0)
    ap "Free Items:"
    ap free_items
    free_items.each do |item|
      total = (BigDecimal.new(item.price) * item.qtyFree) + total
    end
    ap "Calculating free total: #{total}"
    total
  end

  def free_left
    to_dict[:totalHostessBenefitsSix] - to_dict[:freeTotal]
  end

  def free_left_dollars
    fl = free_left
    str = "#{Dolarizer.d(free_left.abs)} "

    if fl > 0
      str << "left"
    else
      str << "over"
    end
    str
  end

  def grandTotal
    to_dict[:totalDue]
  end

  def jewelry_percentage
    jp = (h.jewelryPercentage > -1) ? h.jewelryPercentage : 30

    # If it's a catalog show, completely ignore if 30-40-50 is on.
    return jp if jp == 20

    if h.promotion304050.to_bool == true
      # Get the levels and the total retail+1/2 price
      showTotalWithHalfPrice = h.showTotal + half_price_total
      fourtyPctTrigger = h.promotion304050Trigger40
      fiftyPctTrigger  = h.promotion304050Trigger50

      # DLog(@"showTotalWithHalfPrice %f", showTotalWithHalfPrice);
      # DLog(@"fiftyPctTrigger %f", fiftyPctTrigger);
      # DLog(@"fiftyPctTrigger %f", fiftyPctTrigger);

      if showTotalWithHalfPrice >= fiftyPctTrigger
        return 50
      elsif showTotalWithHalfPrice >= fourtyPctTrigger
        return 40
      end
    end
    jp
  end

  def to_dict
    # Init Hash
    to_dict = {}

    # Jewelry Percentage
    to_dict[:jewelryPercentage] = BigDecimal.new(jewelry_percentage)
    ap "jewelryPercentage: #{desc(to_dict[:jewelryPercentage])}"

    # Bonuses
    bonusTotal = 0
    if to_dict[:jewelryPercentage] != 20 # Don't calculate bonuses on a catalog show.
      [h.bonus1, h.bonus2, h.bonus3, h.bonus4].each do |bonus|
        bonusTotal = bonusTotal + 1 if bonus.to_bool == true
      end
    end
    ap "Total Bonuses: #{desc(bonusTotal)}"

    # Calculate the total award value
    to_dict[:awardValueTotal5] = BigDecimal.new((h.bonusValue * bonusTotal) + h.bonusExtra)
    ap "awardValueTotal5: #{desc(to_dict[:awardValueTotal5])}"

    # Total Retail + Half price selections (3)
    to_dict[:retailPlusHalf] = BigDecimal.new(h.showTotal) + half_price_total
    ap "retailPlusHalf: #{desc(to_dict[:retailPlusHalf])}"

    # Four
    to_dict[:equalsFour] = BigDecimal.new(to_dict[:retailPlusHalf]) * (to_dict[:jewelryPercentage] / 100.0)
    ap "equalsFour: #{desc(to_dict[:equalsFour])}"

    # Total Hostess Benefits
    to_dict[:totalHostessBenefitsSix] = to_dict[:equalsFour] + to_dict[:awardValueTotal5]
    ap "totalHostessBenefitsSix: #{desc(to_dict[:totalHostessBenefitsSix])}"

    to_dict[:freeTotal] = free_total

    # Subtotal One A+B+C
    to_dict[:subtotalOneABC] = half_price_total + to_dict[:freeTotal] + h.shipping
    ap "subtotalOneABC: #{desc(to_dict[:subtotalOneABC])}"

    # Tax
    # Determine if shipping is taxed or not
    shipping_tax = 0.0
    if h.tax_shipping? == false
      shipping_tax = shipping_rate * tax_rate
      ap "Subtract this much if shipping isn't taxed: #{shipping_tax}"
    end

    to_dict[:taxTotal] = ((to_dict[:subtotalOneABC] * tax_rate).round(3) - shipping_tax).currency_round
    ap "Calculation: (#{to_dict[:subtotalOneABC]} * #{tax_rate}) - #{shipping_tax}"
    ap "taxTotal: #{desc(to_dict[:taxTotal])}"

    # Subtotal 2
    to_dict[:subtotalTwo] = to_dict[:taxTotal] + to_dict[:subtotalOneABC]
    ap "subtotalTwo: #{desc(to_dict[:subtotalTwo])}"

    if to_dict[:totalHostessBenefitsSix] < to_dict[:freeTotal].to_f
      minusToGetTotal = BigDecimal.new(to_dict[:totalHostessBenefitsSix])
    else
      minusToGetTotal = to_dict[:freeTotal]
    end

    to_dict[:minusToGetTotal] = minusToGetTotal
    ap "minusToGetTotal: #{desc(to_dict[:minusToGetTotal])}"

    # Discount
    finalDiscount = (BigDecimal.new(h.addtlDiscount) > 0) ? BigDecimal.new(h.addtlDiscount) : BigDecimal.new(0)
    to_dict[:finalDiscount] = finalDiscount

    # Charge
    finalCharge = (BigDecimal.new(h.addtlCharge) > 0) ? BigDecimal.new(h.addtlCharge) : BigDecimal.new(0)
    to_dict[:finalCharge] = finalCharge

    totalDue = to_dict[:subtotalTwo] - to_dict[:minusToGetTotal] - finalDiscount + finalCharge
    to_dict[:totalDue] = totalDue

    to_dict
  end

  def totalRetail
	   h.showTotal
  end

  def desc(value)
    "#{value} (#{value.class})"
  end
end
