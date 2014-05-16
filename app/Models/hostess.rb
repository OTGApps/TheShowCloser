class Hostess < MotionDataWrapper::Model

  def create(options={})
    ap 'created'
    ap options
  end

  def set_and_save(values)
    values.each do |k,v|
      self.send("#{k}=", v)
    end
    self.save
  end

  def has_free_item?(item_number)

  end

  def has_halfprice_item?(item_number)

  end

  def method_missing(meth, *args)
    obj_c_meth = "set" << meth.split('_').inject([]){ |buffer,e| buffer.push(e.capitalize) }.join.delete("=")
    if respond_to?(obj_c_meth)
      send obj_c_meth, *args
    else
      warn NoMethodError.new("Method not implemented on Hostess model: #{meth.to_s}")
    end
  end

end
