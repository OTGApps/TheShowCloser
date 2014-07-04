class Hash
  # Access hash objects with dot notation
  def method_missing(meth, *args)
    if meth.include?("_")
      reverse_case = meth.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    else
      reverse_case = false
    end

    if self[meth.to_s]
      self[meth.to_s]
    elsif self[meth.to_s.to_sym]
      self[meth.to_s.to_sym]
    elsif reverse_case && self[reverse_case]
      self[reverse_case]
    else
      warn NoMethodError.new("No method on Hash: #{meth}")
      false
    end
  end
end
