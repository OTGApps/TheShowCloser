class GlobalSettingsScreen < Formotion::FormController

  def viewDidLoad
    super
    self.title = "Global Settings"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemStop, target:self, action:"close")
    # Flurry.logEvent "SettingsView" unless Device.simulator?
  end

  def init

    @form ||= Formotion::Form.new({
      sections: [{
        title: "These settings will be the default for new hostesses. Changing these values will not affect previously created hostesses.",
        rows: []
      },{
        title: "Tax & Shipping:",
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
        },{
          title: "Shipping Price",
          key: :kShippingRate,
          type: :currency,
          value: App::Persistence['kShippingRate']
        }]
      },{
        title: "Preferences:",
        rows: [{
          title: "Your Name",
          key: :kReceiptName,
          type: :text,
          value: App::Persistence['kReceiptName']
        }, {
          title: "Lock in portrait orientation",
          key: :kLockPortraitMode,
          type: :switch,
          value: App::Persistence['kLockPortraitMode']
        }]
      }, {
        title: "#{App.name} is open source:",
        rows: [{
          title: "View on GitHub",
          type: :github_link,
          image: "icon_github",
          warn: true,
          value: "https://github.com/MohawkApps/BeerJudge"
        }, {
          title: "Found a bug?",
          subtitle: "Log it here.",
          type: :issue_link,
          image: "icon_issue",
          warn: true,
          value: "https://github.com/MohawkApps/BeerJudge/issues/"
        }, {
          title: "Email me suggestions!",
          subtitle: "I'd love to hear from you",
          type: :email_me,
          image: "icon_email",
          value: {
            to: "mark@mohawkapps.com",
            subject: "#{App.name} App Feedback"
          }
        }]
      }, {
        title: "Tell Your friends:",
        rows: [{
          title: "Share the app",
          subtitle: "Text, Email, Tweet, or Facebook!",
          type: :share,
          image: "icon_share",
          value: {
            items: "I'm using the #{App.name} app. Check it out! http://www.mohawkapps.com/app/theshowcloser/",
            excluded: [
              UIActivityTypeAddToReadingList,
              UIActivityTypeAirDrop,
              UIActivityTypeCopyToPasteboard,
              UIActivityTypePrint
            ]
          }
        },{
          title: "Rate on iTunes",
          type: :rate_itunes,
          image: "icon_itunes"
        }]
      }, {
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
