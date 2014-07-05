class WishlistItem < CDQManagedObject

  def copyWithZone(zone)
    Jewelry.allocWithZone(zone).init.tap do |j|
      j.item = self.item.copy
      j.name = self.name.copy
      j.price = self.price.copy
      j.pages = self.pages.copy
      j.type = self.type.copy
      j.retired = (self.retired || 0).boolValue
      j.stopSell = (self.stopSell || 0).boolValue
      j.qtyHalfPrice = 0
      j.qtyFree = 0
    end
  end

  def price=(p)
    self.setPrice BigDecimal.new(p).to_f
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
