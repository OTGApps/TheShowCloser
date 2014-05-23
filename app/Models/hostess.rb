class Hostess < CDQManagedObject

  def set_and_save(values)
    values.each do |k,v|
      self.send("#{k}=", v)
    end
    cdq.save
  end

  # Has
  def has_free?(item_number)
    !free_item(item_number).nil?
  end

  def has_halfprice?(item_number)
    !halfprice_item(item_number).nil?
  end

  # Count
  def free_count(item_number)
    (free_item(item_number).nil?) ? 0 : free_item(item_number).qtyFree
  end

  def halfprice_count(item_number)
    (halfprice_item(item_number).nil?) ? 0 : halfprice_item(item_number).qtyHalfPrice
  end

  # Set
  def set_free(item_number, count)
    ap "Setting item #{item_number} free: #{count}"
    if item(item_number)
      my_item = item(item_number)
      my_item.qtyFree = count.to_i
      cdq.save
    else
      self.wishlist.create(item: item_number.to_i, qtyFree:count.to_i)
    end
    clean_up_item(item_number)
  end

  def set_halfprice(item_number, count)
    ap "Setting item #{item_number} half price: #{count}"
    if item(item_number)
      my_item = item(item_number)
      my_item.qtyHalfPrice = count.to_i
      cdq.save
    else
      self.wishlist.create(item: item_number.to_i, qtyHalfPrice:count.to_i)
    end
    clean_up_item(item_number)
  end

  def clean_up_item(item_number)
    i = item(item_number)
    return if i.nil?
    if i.qtyFree == 0 && i.qtyHalfPrice == 0
      i.destroy
      cdq.save
    end
    App.notification_center.post 'ReloadJewelryTableNotification'
  end

  # Find
  def item(item_number)
    self.wishlist.where(:item).eq(item_number.to_i).first
  end

  def free_item(item_number)
    self.wishlist.where(:item).eq(item_number.to_i).and(cdq(:qtyFree).gt(0)).first
  end

  def halfprice_item(item_number)
    self.wishlist.where(:item).eq(item_number.to_i).and(cdq(:qtyHalfPrice).gt(0)).first
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
