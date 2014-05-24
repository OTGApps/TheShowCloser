class Brain

  def h
    Hostesses.shared_hostess.current_hostess
  end

  def getTaxRate
    BigDecimal.new(h.taxEnabled == true ? h.taxRate : 0.0)
  end

  def getShippingRate
    BigDecimal.new(h.shipping)
  end

  def half_price_total
    total = BigDecimal.new(0)
    h.halfprice_items.each do |item|
      total = total + (item.qtyHalfPrice * item.price)
    end
    total / 2
  end

  def free_total
    total = BigDecimal.new(0)
    h.free_items.each do |item|
      total = total + (item.qtyFree * item.price)
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

    if h.promotion304050 == true
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

    to_dict = {}

    # Bonuses
    bonusTotal = 0

    if jewelry_percentage != 20 # Don't calculate bonuses on a catalog show.
      [h.bonus1, h.bonus2, h.bonus3, h.bonus4].each do |bonus|
        bonusTotal = bonusTotal + 1 if bonus == true
      end
    end

    awardValueTotal5 = (h.bonusValue * bonusTotal) + h.bonusExtra
    to_dict["awardValueTotal5"] = awardValueTotal5

    # Total Retail + Half price selections (3)
    retailPlusHalf = BigDecimal.new(h.showTotal) + half_price_total
    to_dict["retailPlusHalf"] = retailPlusHalf

    # Jewelry Percentage
    to_dict["jewelryPercentage"] = jewelry_percentage

    # Four
    equalsFour = retailPlusHalf * (jewelry_percentage / 100.0)
    to_dict["equalsFour"] = equalsFour

    # Total Hostess Benefits
    totalHostessBenefitsSix = equalsFour + awardValueTotal5
    to_dict["totalHostessBenefitsSix"] = totalHostessBenefitsSix

    # Subtotal One A+B+C
    subtotalOneABC = half_price_total + free_total + getShippingRate
    to_dict["subtotalOneABC"] = subtotalOneABC

    # Tax
    # Determine if shipping is taxed or not
    shipping_tax = 0.0
    if h.taxShipping == false
      shipping_tax = (getShippingRate.to_f * (getTaxRate / 100))
      # DLog("Subtract this much if shipping isn't taxed: %f", shipping_tax)
    end

    taxTotalUnrounded = NSNumber.numberWithFloat((subtotalOneABC.floatValue * h.tax_rate / 100.0) - shipping_tax)
    taxTotal = taxTotalUnrounded.currencyRound
    to_dict["taxTotal"] = taxTotal

    # Subtotal 2
    subtotalTwo = BigDecimal.new(taxTotal) + subtotalOneABC
    to_dict["subtotalTwo"] = subtotalTwo

    if totalHostessBenefitsSix < free_total.to_f
      minusToGetTotal = BigDecimal.new(totalHostessBenefitsSix)
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
end
