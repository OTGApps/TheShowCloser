class Hostesses

  attr_accessor :current_hostess

  def self.shared_hostess
    Dispatch.once { @instance ||= new }
    @instance
  end

end
