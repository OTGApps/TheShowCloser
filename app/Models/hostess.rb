class Hostess < MotionDataWrapper::Model

  def create options={}
    ap 'created'
    ap options
  end

end
