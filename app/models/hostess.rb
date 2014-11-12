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
    item = free_item(item_number)
    (item.nil?) ? 0 : item.qtyFree
  end

  def halfprice_count(item_number)
    item = halfprice_item(item_number)
    (item.nil?) ? 0 : item.qtyHalfPrice
  end

  # Set
  def set_free(item_number, count, cleanup = true)
    p "Setting item #{item_number} free: #{count}"
    if item(item_number)
      my_item = item(item_number)
      my_item.qtyFree = count.to_i
    else
      item_data = JewelryData.data.item_data(item_number)
      self.wishlist.create(item_data.merge({qtyFree:count.to_i}))
    end
    cdq.save
    clean_up_item(item_number) if cleanup
  end

  def set_halfprice(item_number, count, cleanup = true)
    p "Setting item #{item_number} half price: #{count}"
    if item(item_number)
      my_item = item(item_number)
      my_item.qtyHalfPrice = count.to_i
    else
      item_data = JewelryData.data.item_data(item_number)
      self.wishlist.create(item_data.merge({qtyHalfPrice:count.to_i}))
    end
    cdq.save
    clean_up_item(item_number) if cleanup
  end

  def clean_up_item(item_number)
    i = item(item_number)
    unless i.nil?
      if i.qtyFree == 0 && i.qtyHalfPrice == 0
        i.destroy
        cdq.save
      end
    end
    App.notification_center.post 'ReloadJewelryTableNotification'
  end

  # Clear
  def clear_free
    items.each do |i|
      i.qtyFree = 0
      i.destroy if i.qtyFree == 0 && i.qtyHalfPrice == 0
    end
    cdq.save
    App.notification_center.post 'ReloadJewelryTableNotification'
  end

  def clear_halfprice
    items.each do |i|
      i.qtyHalfPrice = 0
      i.destroy if i.qtyFree == 0 && i.qtyHalfPrice == 0
    end
    cdq.save
    App.notification_center.post 'ReloadJewelryTableNotification'
  end

  # Find
  def items
    self.wishlist.all
  end

  def free_items
    self.wishlist.where(:qtyFree).gt(0).all
  end

  def halfprice_items
    self.wishlist.where(:qtyHalfPrice).gt(0).all
  end

  def item(item_number)
    self.wishlist.where(:item).eq(item_number.to_i).first
  end

  def free_item(item_number)
    self.wishlist.where(:item).eq(item_number.to_i).and(cdq(:qtyFree).gt(0)).first
  end

  def halfprice_item(item_number)
    self.wishlist.where(:item).eq(item_number.to_i).and(cdq(:qtyHalfPrice).gt(0)).first
  end

  def new_hostess_plan?
    new_bonuses_date = "2013-07-27"
    formatter = NSDateFormatter.alloc.init
    formatter.setDateFormat("yyyy-MM-dd")
    createdDate.later_than?(formatter.dateFromString(new_bonuses_date))
  end

  def tax_enabled?
    taxEnabled.to_bool
  end

  def tax_shipping?
    taxShipping.to_bool
  end

  def first_name
    s = name.split(' ')
    (s.count > 1) ? s[0] : nil
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

  def copyWithZone(zone)
    c = {}
    self.attributes.keys.each do |a|
      c[a] = self.send(a)
    end
    c
  end
end
