class BigDecimal
  def to_s
    self.stringValue
  end

  def to_f
    self.floatValue
  end

  def to_i
    self.intValue
  end

  def to_ll
    self.longLongValue
  end

  def currencyRound
    BigDecimal.new(NSNumber.numberWithFloat(self.to_f).currencyRound)
  end
end
