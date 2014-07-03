class Dolarizer
  def self.d(number)
    return number if number.is_a?(String)
    d = sprintf("$%.2f", number)
    if d.end_with?('.00')
      d[0...-3]
    else
      d
    end
  end
end
