class HostessScreen < PM::TableScreen
  # searchable
  title "Your Hostesses"

  def on_load
    set_nav_bar_button :right, system_item: :add, action: :add_hostess
    set_toolbar_items [{
        image: UIImage.imageNamed("jewelry"),
        action: :show_quick_lookup,
      }, {
        system_item: :flexible_space
      }, {
        title: "Global Settings",
        action: :show_global_options,
      }]
    # ap Hostess.destroy_all!
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
    Hostess.sort_by(:createdDate, order: :descending).collect do |h|
      {
        title: h.name,
        subtitle: subtitle(h),
        cell_style: UITableViewCellStyleSubtitle,
        accessory_type: :disclosure_indicator,
        selection_style: :gray,
        editing_style: :delete, # Swipe-to-delete
        action: :pick_hostess,
        arguments: {
          hostess: h
        }
      }
    end
  end

  def subtitle(hostess)
    s = []
    s << hostess.createdDate.short_date
    s << Dolarizer.d(hostess.showTotal) if hostess.showTotal > 0
    s.join(" - ")
  end

  def add_hostess
    ap "Adding new hostess"

    alert = BW::UIAlertView.plain_text_input(title: 'Enter Hostess Name:') do |a|
      if alert.clicked_button.index > 0
        ap "Got: #{a.plain_text_field.text}"

        h = Hostess.create(
          name: a.plain_text_field.text,
          createdDate: Time.now,
          shipping: BigDecimal.new(App::Persistence['kShippingRate']).to_f,
          taxEnabled: App::Persistence['kTaxEnabled'],
          taxRate: BigDecimal.new(App::Persistence['kTaxRate']).to_f,
          taxShipping: App::Persistence['kTaxShipping']
        )
        cdq.save
        update_table_data

        new_cell = NSIndexPath.indexPathForRow(0, inSection:0)
        data_cell = self.promotion_table_data.cell(index_path: new_cell)
        trigger_action(data_cell[:action], data_cell[:arguments]) if data_cell[:action]
      end
    end
    alert_field = alert.textFieldAtIndex(0)
    alert_field.autocapitalizationType = UITextAutocapitalizationTypeWords
    alert_field.autocorrectionType = UITextAutocorrectionTypeNo
    alert.show
  end

  def pick_hostess(args)
    ap args
    Hostesses.shared_hostess.current_hostess = args[:hostess]
    App.notification_center.post "PickedHostessNotification"
    App.delegate.slide_menu.hide
  end

  def on_cell_deleted(cell)
    cell[:arguments][:hostess].destroy
    cdq.save
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
    open_modal QuickLookupScreen.new(nav_bar:true, presentation_style: UIModalPresentationFormSheet)
  end

  def db_update_check
    ap "Checking for a database update."
    jd = JewelryDownloader.new
    jd.check
  end

end
