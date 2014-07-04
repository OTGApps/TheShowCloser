class Brain < BrainMaster
  def self.app_brain
    Dispatch.once { @instance ||= new }
    @instance
  end

  def h
    Hostesses.shared_hostess.current_hostess
  end

  def halfprice_items
    h.halfprice_items
  end

  def free_items
    h.free_items
  end

end
