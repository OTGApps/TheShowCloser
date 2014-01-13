class GlobalSettingsScreen < Formotion::FormController

  def viewDidLoad
    super
    self.title = "Global Settings"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemStop, target:self, action:"close")
    # Flurry.logEvent "SettingsView" unless Device.simulator?
  end

  def set_defaults
    App::Persistence['kTaxEnabled'] ||= true
    App::Persistence['kTaxRate']    ||= 6.75
    App::Persistence['kTaxShipping']||= true
    App::Persistence['kReceiptName']||= "Your Favorite Jewelry Lady"
  end

  def init
    set_defaults

    @form ||= Formotion::Form.new({
      sections: [{
        title: "These settings will be the default for new hostesses. Changing these values will not affect previously created hostesses.",
        rows: []
      },{
        title: "Tax:",
        rows: [{
          title: "Enable Tax?",
          key: :kTaxEnabled,
          type: :switch,
          value: App::Persistence['kTaxEnabled']
        },{
          title: "Tax Rate(%)",
          key: :kTaxRate,
          type: :number,
          value: App::Persistence['kTaxRate']
        },{
          title: "Tax Shipping?",
          key: :kTaxShipping,
          type: :switch,
          value: App::Persistence['kTaxShipping']
        }]
      },{
        title: "Preferences:",
        rows: [{
          title: "Your Name",
          key: :kReceiptName,
          type: :text,
          value: App::Persistence['kReceiptName']
        }]
      },{
        title: "About:",
        rows: [{
          title: "Version",
          type: :static,
          placeholder: App.info_plist['CFBundleShortVersionString'],
          selection_style: :none
        }, {
          title: "Copyright",
          type: :static,
          font: { name: 'HelveticaNeue', size: 13 },
          placeholder: "#{copyright_year} Mohawk Apps, LLC",
          selection_style: :none
        }, {
          title: "Email me suggestions!",
          subtitle: "I'd love to hear from you",
          type: :email_me,
          image: "email",
          value: {
            to: "mark@mohawkapps.com",
            subject: "#{App.name} App Feedback"
          }
        }, {
          title: "Visit MohawkApps.com",
          type: :web_link,
          warn: false,
          value: "http://www.mohawkapps.com"
        }, {
          title: "Made with ♥ in North Carolina",
          type: :static,
          enabled: false,
          selection_style: :none,
          text_alignment: NSTextAlignmentCenter
        },{
          type: :static_image,
          value: "nc",
          enabled: false,
          selection_style: :none
        }]
      }]
    })
    super.initWithForm(@form)
  end

  def copyright_year
    start_year = '2012'
    this_year = Time.now.year

    start_year == this_year ? this_year : "#{start_year}-#{this_year}"
  end


  def close
    data = @form.render
    ap data

    data.each do |key, value|
      App::Persistence[key.to_s] = value
    end

    dismissModalViewControllerAnimated(true)
  end

end
