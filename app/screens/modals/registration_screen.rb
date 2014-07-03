# Customize the save button
module Formotion
  class Form < Formotion::Base
    def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
      if cell.textLabel.text.start_with?("Save")
        cell.backgroundColor = "#7B4289".to_color
        cell.textLabel.textColor = UIColor.whiteColor
      end
    end
  end
end

class RegistrationScreen < Formotion::FormController

  def viewDidLoad
    super
    self.title = "Welcome to #{App.name}!"
  end

  def init
    @form ||= Formotion::Form.new({
      sections: [{
        title: "Welcome to The Show Closer! Please enter your Jeweler Number.\n\nWe use this on your emailed receipts and to make sure you have the most up to date jewelry catalog data.",
        rows: [{
          title: "Jeweler Number:",
          key: :jeweler_number,
          clear_button: :never,
          type: :number
        }]
      }, {
        title: nil,
        rows: [{
          title: "Save Jeweler Number",
          type: :submit,
        }]
      },{
        title: "An Internet connection is required for catalog data downloads. Your first catalog download is free, subsequent catalog data updates require an in app purchase (See App Store description for details)."
      },{
        title: "This application is sold and maintained by Mohawk Apps, LLC and is not endorsed by or afilliated with any other company."
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