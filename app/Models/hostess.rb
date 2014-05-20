class Hostess < CDQManagedObject

  def set_and_save(values)
    values.each do |k,v|
      self.send("#{k}=", v)
    end
    cdq.save
  end

  def has_free?(item_number)
    !self.wishlist.find{ |wli| wli.item == item_number || wli.qtyFree > 0 }.nil?
  end

  def has_halfprice?(item_number)
    !self.wishlist.find{ |wli| wli.item == item_number && wli.qtyHalfPrice > 0 }.nil?
  end

  def method_missing(meth, *args)
    obj_c_meth = "set" << meth.split('_').inject([]){ |buffer,e| buffer.push(e.capitalize) }.join.delete("=")
    if respond_to?(obj_c_meth)
      send obj_c_meth, *args
    else
      warn NoMethodError.new("Method not implemented on Hostess model: #{meth.to_s}")
      false
    end
  end
end
