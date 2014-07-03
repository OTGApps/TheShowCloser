class BigDecimal
  def currency_round
    format = NSNumberFormatter.alloc.init
    format.setNumberStyle(NSNumberFormatterDecimalStyle)
    format.setRoundingMode(NSNumberFormatterRoundHalfUp)
    format.setMaximumFractionDigits(2)
    format.setMinimumFractionDigits(2)

    BigDecimal.new(format.stringFromNumber(self))
  end

  def round(precision)
    BigDecimal.new(self.to_f.round(precision))
  end
end
