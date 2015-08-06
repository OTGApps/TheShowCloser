class AppLogger
  def self.log(event = '', parameters = nil)
    unless Device.simulator?
      Crittercism.leaveBreadcrumb(event)
      # if parameters
      #   Flurry.logEvent(event, withParameters: parameters)
      # else
      #   Flurry.logEvent(event)
      # end
    end
  end
end
