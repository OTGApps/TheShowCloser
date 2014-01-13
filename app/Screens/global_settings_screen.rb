class GlobalSettingsScreen < Formotion::FormController
  include BW::KVO

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
        title: "Tax:",
        rows: [{
          title: "Enable Tax?",
          key: :kTaxEnabled,
          type: :switch,
          value: App::Persistence['kTaxEnabled'] || true
        }]
      }]
    })
    super.initWithForm(@form)
  end

  def observe
    tax_enabled = self.form.sections[1].rows[0]
    observe(tax_enabled, "value") do |old_value, new_value|
      App::Persistence['kTaxEnabled'] = new_value
    end
  end

  def close
    dismissModalViewControllerAnimated(true)
  end

end
