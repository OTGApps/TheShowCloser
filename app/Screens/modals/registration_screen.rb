class RegistrationScreen < Formotion::FormController

  def viewDidLoad
    super
    self.title = "Welcome to #{App.name}!"
  end

  def init
    @form ||= Formotion::Form.new({
      sections: [{
        title: "\nPlease enter your Jeweler Number.\n\nWe use this on your emailed receipts and to make sure you have the most up to date jewelry catalog data.",
        rows: [{
          title: "Jeweler Number:",
          key: :jeweler_number,
          clear_button: :never,
          type: :number
        }]
      }, {
        title: nil,
        rows: [{
          title: "Set Jeweler Number",
          type: :submit,
        }]
      }]
    })

    @form.on_submit do |form|
      jn = form.render[:jeweler_number]

      if jn.length < 4 || jn.include?(".")
        App.alert("Invalid", message: "It appears that your Jeweler number is invalid. Please try again.")
      else
        App::Persistence['jeweler_number'] = jn
        dismissModalViewControllerAnimated(true)
      end

    end

    super.initWithForm(@form)
  end

end
