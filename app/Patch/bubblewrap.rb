class BubbleWrap::App
  class << self
    # Use my name I specify in the app info plist.
    alias_method :short_name, :name
    def name
      App.info_plist['FULL_APP_NAME'] || ''
    end
  end
end
