class Hostess < MotionDataWrapper::Model

  def create(options={})
    ap 'created'
    ap options
  end

  def method_missing(meth, *args)
    obj_c_meth = "set" << meth.split('_').inject([]){ |buffer,e| buffer.push(e.capitalize) }.join.delete("=")
    if respond_to?(obj_c_meth)
      send obj_c_meth, *args
    else
      raise NoMethodError.new(meth.to_s)
    end
  end

end
