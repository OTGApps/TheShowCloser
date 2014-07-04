class BrainMaster
  def tax_rate
    ((h.tax_enabled?) ? h.tax_rate : BigDecimal.new(0.0)) / 100.00
  end

  def shipping_rate
    h.shipping_rate
  end

  def shipping_total
    (h.tax_shipping?) ? shipping_rate * (tax_rate + 1) : shipping_rate
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
    to_dict[:subtotalOneABC] = half_price_total + to_dict[:freeTotal] + h.shipping
    # p "subtotalOneABC: #{to_dict[:subtotalOneABC]}"

    # Tax
    # Determine if shipping is taxed or not
    shipping_tax = 0.0
    if h.tax_shipping? == false
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
end