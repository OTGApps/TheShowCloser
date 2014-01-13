class HostessScreen < PM::TableScreen
  # searchable
  title "Your Hostesses"

  def on_load
    set_nav_bar_button :right, system_icon: :add, action: :add_hostess
    set_toolbar_items [{
        system_item: :flexible_space
      }, {
        title: "Global Settings",
        action: :show_global_options,
      }]
    # ap Hostess.destroy_all
  end

  def table_data
  [{
    title: nil,
    cells: all_hostesses
  }]
  end

  def all_hostesses
    Hostess.all.sort_by { |h| h.showDate }.reverse.collect do |h|
      {
        title: h.name,
        subtitle: h.showDate.to_s,
        cell_style: UITableViewCellStyleSubtitle,
        accessory_type: UITableViewCellAccessoryDisclosureIndicator,
        selection_style: UITableViewCellSelectionStyleGray,
        editing_style: :delete, # Swipe-to-delete
        action: :pick_hostess,
        arguments: {
          hostess: h
        }
      }
    end
  end

  def add_hostess
    ap "Adding new hostess"

    alert = BW::UIAlertView.plain_text_input(title: 'Enter Hostess Name:') do |a|
      if alert.clicked_button.index > 0
        ap "Got: #{a.plain_text_field.text}"

        h = Hostess.create(name: a.plain_text_field.text, showDate: Time.now)
        ap h
        update_table_data
      end
    end
    # TODO - make this acutually work.
    alert_field = alert.textFieldAtIndex(0)
    # ap alert_field
    alert_field.autocapitalizationType = UITextAutocapitalizationTypeWords
    alert_field.autocorrectionType = UITextAutocorrectionTypeNo
    alert.show
  end

  def pick_hostess(args)
    ap "Picked hostess:"
    ap args
  end

  def on_cell_deleted(cell)
    cell[:arguments][:hostess].destroy
    true
  end

  def show_global_options
    options_screen = GlobalSettingsScreen.alloc.init
    options = UINavigationController.alloc.initWithRootViewController(options_screen)
    options.modalPresentationStyle = UIModalPresentationFormSheet
    self.presentModalViewController(options, animated:true)
  end
end
