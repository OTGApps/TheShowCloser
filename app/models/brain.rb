class Brain
  attr_accessor :hostess, :jewelry_combo

  def self.app_brain
    Dispatch.once { @instance ||= new }
    @instance
  end

  def h
    if @jewelry_combo.nil?
      Hostesses.shared_hostess.current_hostess
    else
      @hostess
    end
  end

  def halfprice_items
    if @jewelry_combo.nil?
      h.halfprice_items
    else
      @jewelry_combo[:items].each_index do |i|
        @jewelry_combo[:items][i].qtyFree = 0
        @jewelry_combo[:items][i].qtyHalfPrice = (@jewelry_combo[:combo][i] == :half) ? 1 : 0
      end
      @jewelry_combo[:items].select{|i| i.qtyHalfPrice == 1 }
    end
  end

  def free_items
    if @jewelry_combo.nil?
      h.free_items
    else
      @jewelry_combo[:items].each_index do |i|
        @jewelry_combo[:items][i].qtyHalfPrice = 0
        @jewelry_combo[:items][i].qtyFree = (@jewelry_combo[:combo][i] == :free) ? 1 : 0
      end
      @jewelry_combo[:items].select{|i| i.qtyFree == 1 }
    end
  end

  def tax_rate
    tax_rate_whole / 100.0
  end

  def tax_rate_whole
    ((tax_enabled?) ? BigDecimal.new(h.taxRate.round(3) || 0.0) : BigDecimal.new(0.0))
  end

  def shipping_rate
    BigDecimal.new(h.shipping.round(3) || 0.0)
  end

  def shipping_total
    (tax_shipping?) ? shipping_rate * (tax_rate + 1) : shipping_rate
  end

  def half_price_total
    total = BigDecimal.new(0)
    halfprice_items.each do |item|
      total = (BigDecimal.new(item.price) * item.qtyHalfPrice) + total
    end
    total / 2
  end

  def free_total
    total = BigDecimal.new(0)
    free_items.each do |item|
      total = (BigDecimal.new(item.price) * item.qtyFree) + total
    end
    total
  end

  def free_left
    data = calculate
    data[:totalHostessBenefitsSix] - data[:freeTotal]
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
    calculate[:totalDue]
  end

  def jewelry_percentage
    jp = (h.jewelryPercentage > -1) ? h.jewelryPercentage : 30

    # If it's a catalog show, completely ignore if 30-40-50 is on.
    return jp if jp == 20

    if promotion304050?
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

  def calculate
    # Init Hash
    to_dict = {}

    # Jewelry Percentage
    to_dict[:jewelryPercentage] = BigDecimal.new(jewelry_percentage)
    # p "jewelryPercentage: #{to_dict[:jewelryPercentage]}"

    # Bonuses
    bonusTotal = 0
    if to_dict[:jewelryPercentage] != 20 # Don't calculate bonuses on a catalog show.
      [h.bonus1, h.bonus2, h.bonus3, h.bonus4].each do |bonus|
        bonusTotal = bonusTotal + 1 if bonus.to_bool == true
      end
    end
    # p "Total Bonuses: #{bonusTotal}"

    # Calculate the total award value
    to_dict[:awardValueTotal5] = BigDecimal.new((h.bonusValue * bonusTotal) + h.bonusExtra)
    # p "awardValueTotal5: #{to_dict[:awardValueTotal5]}"

    # Total Retail + Half price selections (3)
    to_dict[:retailPlusHalf] = BigDecimal.new(h.showTotal) + half_price_total
    # p "retailPlusHalf: #{to_dict[:retailPlusHalf]}"

    # Four
    to_dict[:equalsFour] = BigDecimal.new(to_dict[:retailPlusHalf]) * (to_dict[:jewelryPercentage] / 100.0)
    # p "equalsFour: #{to_dict[:equalsFour]}"

    # Total Hostess Benefits
    to_dict[:totalHostessBenefitsSix] = to_dict[:equalsFour] + to_dict[:awardValueTotal5]
    # p "totalHostessBenefitsSix: #{to_dict[:totalHostessBenefitsSix]}"

    to_dict[:freeTotal] = free_total

    # Subtotal One A+B+C
    to_dict[:subtotalOneABC] = half_price_total + to_dict[:freeTotal] + shipping_rate
    # p "subtotalOneABC: #{to_dict[:subtotalOneABC]}"

    # Tax
    # Determine if shipping is taxed or not
    shipping_tax = 0.0
    if tax_shipping? == false
      shipping_tax = shipping_rate * tax_rate
      # p "Subtract this much if shipping isn't taxed: #{shipping_tax}"
    end

    to_dict[:taxTotal] = ((to_dict[:subtotalOneABC] * tax_rate).round(3) - shipping_tax).currency_round
    # p "Calculation: (#{to_dict[:subtotalOneABC]} * #{tax_rate}) - #{shipping_tax}"
    # p "taxTotal: #{to_dict[:taxTotal]}"

    # Subtotal 2
    to_dict[:subtotalTwo] = to_dict[:taxTotal] + to_dict[:subtotalOneABC]
    # p "subtotalTwo: #{to_dict[:subtotalTwo]}"

    if to_dict[:totalHostessBenefitsSix] < to_dict[:freeTotal].to_f
      minusToGetTotal = BigDecimal.new(to_dict[:totalHostessBenefitsSix])
    else
      minusToGetTotal = to_dict[:freeTotal]
    end

    to_dict[:minusToGetTotal] = minusToGetTotal
    # p "minusToGetTotal: #{to_dict[:minusToGetTotal]}"

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

  def tax_enabled?
    h.taxEnabled.to_bool
  end

  def tax_shipping?
    h.taxShipping.to_bool
  end

  def promotion304050?
    h.promotion304050.to_bool
  end

end
