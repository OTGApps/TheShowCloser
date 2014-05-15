class HostessScreen < PM::TableScreen
  # searchable
  title "Your Hostesses"

  def on_load
    set_nav_bar_button :right, system_icon: :add, action: :add_hostess
    set_toolbar_items [{
        image: UIImage.imageNamed("jewelry"),
        action: :show_quick_lookup,
      }, {
        system_item: :flexible_space
      }, {
        title: "Global Settings",
        action: :show_global_options,
      }]
    # ap Hostess.destroy_all
  end

  def on_appear
    # Check for Jewelry Database update
    unless App::Persistence['jeweler_number']
      show_registration
    else
      db_update_check
      update_table_data
    end
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
        subtitle: "Show: #{h.showDate.short_date}",
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

        h = Hostess.create(
          name: a.plain_text_field.text,
          showDate: Time.now,
          bonusValue: App::Persistence['kBonusValue'],
          jewelryPercentage: App::Persistence['kJewelryPercentage'],
          shipping: App::Persistence['kShippingRate'],
          taxEnabled: App::Persistence['kTaxEnabled'],to_bool,
          taxRate: App::Persistence['kTaxRate'],
          taxShipping: App::Persistence['kTaxShipping'].to_bool
        )
        ap h
        update_table_data
      end
    end
    alert_field = alert.textFieldAtIndex(0)
    alert_field.autocapitalizationType = UITextAutocapitalizationTypeWords
    alert_field.autocorrectionType = UITextAutocorrectionTypeNo
    alert.show
  end

  def pick_hostess(args)
    Hostesses.shared_hostess.current_hostess = args[:cell][:arguments][:hostess]
    App.notification_center.post "PickedHostessNotification"
    App.delegate.slide_menu.hide
  end

  def on_cell_deleted(cell)
    cell[:arguments][:hostess].destroy
    true
  end

  def show_registration
    options_screen = RegistrationScreen.alloc.init
    options = UINavigationController.alloc.initWithRootViewController(options_screen)
    options.modalPresentationStyle = UIModalPresentationFullScreen
    self.presentModalViewController(options, animated:false)
  end

  def show_global_options
    options_screen = GlobalSettingsScreen.alloc.init
    options = UINavigationController.alloc.initWithRootViewController(options_screen)
    options.modalPresentationStyle = UIModalPresentationFormSheet
    self.presentModalViewController(options, animated:true)
  end

  def show_quick_lookup
    open_modal QuickLookupScreen.new nav_bar:true
  end

  def db_update_check
    ap "Checking for a database update."
    jd = JewelryDownloader.new
    jd.check
  end

end
