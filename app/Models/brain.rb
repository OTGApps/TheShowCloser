class Brain

  def h
    Hostesses.shared_hostess.current_hostess
  end

  def tax_rate
    BigDecimal.new(h.tax_enabled? ? h.taxRate : 0.0) / 100.0
  end

  def shipping_rate
    BigDecimal.new(h.shipping)
  end

  def shipping_total
    (h.tax_shipping?) ? shipping_rate * (tax_rate + 1) : shipping_rate
  end

  def half_price_total
    ap 'Calculating half price total.'
    total = BigDecimal.new(0)
    h.halfprice_items.each do |item|
      total = (BigDecimal.new(item.price) * item.qtyHalfPrice) + total
    end
    total / 2
  end

  def free_total
    total = BigDecimal.new(0)
    h.free_items.each do |item|
      total = (BigDecimal.new(item.price) * item.qtyFree) + total
    end
    total
  end

  def calculateFreeJewelryLeft
    totalFreeWithBenefits - free_total
  end

  def grandTotal
	  to_dict["totalDue"]
  end

  def totalFreeWithBenefits
	  to_dict["totalHostessBenefitsSix"]
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
    formatter = NSNumberFormatter.alloc.init
    formatter.setMaximumFractionDigits(2)
    formatter.setRoundingMode(NSNumberFormatterRoundHalfUp)
    # NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:roundedValue]];

    # Init Hash
    to_dict = {}

    # Jewelry Percentage
    to_dict["jewelryPercentage"] = jewelry_percentage
    ap "jewelryPercentage: #{desc(to_dict['jewelryPercentage'])}"

    # Bonuses
    bonusTotal = 0
    if to_dict["jewelryPercentage"] != 20 # Don't calculate bonuses on a catalog show.
      [h.bonus1, h.bonus2, h.bonus3, h.bonus4].each do |bonus|
        bonusTotal = bonusTotal + 1 if bonus == true
      end
    end
    ap "Total Bonuses: #{desc(to_dict['bonusTotal'])}"

    # Calculate the total award value
    to_dict["awardValueTotal5"] = BigDecimal.new((h.bonusValue * bonusTotal) + h.bonusExtra)
    ap "awardValueTotal5: #{desc(to_dict['awardValueTotal5'])}"

    # Total Retail + Half price selections (3)
    to_dict["retailPlusHalf"] = BigDecimal.new(h.showTotal) + half_price_total
    ap "retailPlusHalf: #{desc(to_dict['retailPlusHalf'])}"

    # Four
    to_dict["equalsFour"] = BigDecimal.new(to_dict["retailPlusHalf"] * (to_dict["jewelryPercentage"] / 100.0))
    ap "equalsFour: #{desc(to_dict['equalsFour'])}"

    # Total Hostess Benefits
    to_dict["totalHostessBenefitsSix"] = to_dict["equalsFour"] + to_dict["awardValueTotal5"]
    ap "totalHostessBenefitsSix: #{desc(to_dict['totalHostessBenefitsSix'])}"

    # Subtotal One A+B+C
    to_dict["subtotalOneABC"] = half_price_total + free_total + h.shipping
    ap "subtotalOneABC: #{desc(to_dict['subtotalOneABC'])}"

    # Tax
    # Determine if shipping is taxed or not
    shipping_tax = 0.0
    if h.taxShipping == false
      shipping_tax = (h.shipping.to_f * tax_rate)
      # DLog("Subtract this much if shipping isn't taxed: %f", shipping_tax)
    end

    taxTotalUnrounded = NSNumber.numberWithFloat((to_dict["subtotalOneABC"].floatValue * tax_rate) - shipping_tax)
    taxTotal = taxTotalUnrounded.currencyRound
    to_dict["taxTotal"] = taxTotal

    # Subtotal 2
    subtotalTwo = BigDecimal.new(taxTotal) + to_dict["subtotalOneABC"]
    to_dict["subtotalTwo"] = subtotalTwo

    if to_dict["totalHostessBenefitsSix"] < free_total.to_f
      minusToGetTotal = BigDecimal.new(to_dict["totalHostessBenefitsSix"])
    else
      minusToGetTotal = free_total
    end

    to_dict["minusToGetTotal"] = minusToGetTotal

    # Discount
    finalDiscount = (BigDecimal.new(h.addtlDiscount) > 0) ? BigDecimal.new(h.addtlDiscount) : BigDecimal.new(0)
    to_dict["finalDiscount"] = finalDiscount

    # Charge
    finalCharge = (BigDecimal.new(h.addtlCharge) > 0) ? BigDecimal.new(h.addtlCharge) : BigDecimal.new(0)
    to_dict["finalCharge"] = finalCharge

    totalDue = subtotalTwo - minusToGetTotal - finalDiscount + finalCharge
    to_dict['totalDue'] = totalDue

    to_dict
  end

  def totalRetail
	   h.showTotal
  end

  def desc(value)
    "#{value} (#{value.class})"
  end
end
