class HomeShowScreen < Formotion::FormController
  include BW::KVO
  include ProMotion::ScreenModule

  def viewDidLoad
    super
    App.notification_center.observe "PickedHostessNotification" do |notification|
      p 'PickedHostessNotification'
      mp ch

      reinit
      self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated:false)
    end
  end

  def reinit
    self.form = build_form
    self.form.controller = self

    reinit_titles

    set_nav_bar_button :left, {
      title: "Hostesses",
      system_item: :reply,
      action: :show_all_hostesses
    }

    # Listen for hostess changes
    observe_switches
  end

  def reinit_titles
    self.setTitle(named_title)
    self.navigationController.tabBarItem.title = "Show"
    self.navigationController.tabBarItem.image = UIImage.imageNamed('homeshow')
  end

  def show_all_hostesses
    App.delegate.slide_menu.anchorRightRevealAmount = Device.screen.width_for_orientation(:landscape_left)
    App.delegate.slide_menu.show(:right)
    unobserve_all
    ch = nil
  end

  def update_and_save_hostess(key = nil)
    return if ch.nil?
    p 'Saving Hostess Data'

    serialized = form.render
    serialized[:created_date] = Time.at(serialized[:created_date])
    serialized[:jewelry_percentage] = serialized[:jewelry_percentage][0...-1].to_i

    # Floatify
    [:tax_rate, :shipping, :show_total, :addtl_discount, :addtl_charge, :promotion304050Trigger40, :promotion304050Trigger50].each do |sym|
      serialized[sym] = "0" if serialized[sym].is_a?(String) && serialized[sym].empty?
      serialized[sym] = BigDecimal.new(serialized[sym]).to_f
    end

    mp serialized

    ch.set_and_save(serialized)
    reinit_titles
  end

  def observe_switches
    return if ch.nil?

    # Observe all switches in the form.
    self.form.sections.each_with_index do |s, si|
      s.rows.each_with_index do |r, ri|
        if r.type == :switch
          observe(self.form.sections[si].rows[ri], "value") do |old_value, new_value|
            # If turning on or off the 30th Anniversary Promo, turn on or off the 30-40-50 promo
            hash = self.form.render
            if self.form.sections[si].rows[ri].key == :promotion30405060 && new_value != hash[:promotion304050]
              self.form.row(:promotion304050).value = new_value
            else
              update_and_save_hostess
            end
          end
        end
      end
    end
  end

  def form_data
    {
      sections: [{
        title: "Show Results:",
        rows: [{
          title: "Total",
          key: :show_total,
          type: :currency,
          value: ch.showTotal,
          input_accessory: :done,
          done_action: default_done_action
        },{
          title: "Earned Bonus 1",
          key: :bonus_1,
          value: ch.bonus1.to_bool,
          type: :switch
        },{
          title: "Earned Bonus 2",
          key: :bonus_2,
          value: ch.bonus2.to_bool,
          type: :switch
        }]
      },{
        title: "About The Show:",
        rows: [{
          title: "Hostess Name",
          key: :name,
          type: :string,
          value: ch.name,
          input_accessory: :done,
          done_action: default_done_action
        },{
          title: "Date",
          key: :created_date,
          type: :date,
          format: :medium,
          value: ch.createdDate.to_i,
          input_accessory: :done,
          done_action: default_done_action
        },{
          title: "Notes",
          key: :notes,
          type: :text,
          value: ch.notes,
          input_accessory: :done,
          done_action: default_done_action,
          row_height: 100
        }]
      },{
        title: "Hostess Benefits:",
        rows: [{
          title: "Free Jewelry",
          key: :jewelry_percentage,
          type: :picker,
          items: ['20%', '30%', '40%', '50%'],
          value: "#{ch.jewelryPercentage.to_s}%",
          input_accessory: :done,
          done_action: default_done_action
        },{
          title: "Bonus Value",
          key: :bonus_value,
          type: :currency,
          value: ch.bonusValue,
          input_accessory: :done,
          done_action: default_done_action
        },{
          title: "Extra Bonus",
          key: :bonus_extra,
          type: :currency,
          input_accessory: :done,
          value: ch.bonusExtra,
          done_action: default_done_action
        }]
      },{
        title: "Taxes & Shipping:",
        rows: [{
          title: "Enable Tax?",
          key: :tax_enabled,
          type: :switch,
          value: ch.tax_enabled?
        },{
          title: "Tax Rate (%)",
          key: :tax_rate,
          type: :number,
          value: Brain.app_brain.tax_rate_whole,
          input_accessory: :done,
          done_action: default_done_action
        },{
          title: "Hostess Shipping",
          key: :shipping,
          type: :currency,
          input_accessory: :done,
          value: Brain.app_brain.shipping_rate,
          done_action: default_done_action
        },{
          title: "Tax Shipping?",
          key: :tax_shipping,
          type: :switch,
          value: ch.tax_shipping?
        }]
      },{
        title: "Special Discounts / Charges:",
        rows: [{
          title: "Additional Discount",
          key: :addtl_discount,
          type: :currency,
          value: ch.addtlDiscount,
          input_accessory: :done,
          done_action: default_done_action
        },{
          title: "Additional Charge",
          key: :addtl_charge,
          type: :currency,
          value: ch.addtlCharge,
          input_accessory: :done,
          done_action: default_done_action
        }]
      },{
        title: "30-40-50 Hostess Promotion",
        rows: [{
          title: "Enable?",
          key: :promotion304050,
          value: ch.promotion304050.to_bool,
          type: :switch,
        },{
          title: "40% Benefits Limit:",
          key: :promotion304050Trigger40,
          value: ch.promotion304050Trigger40 || 400.0,
          type: :currency,
          input_accessory: :done,
          done_action: default_done_action
        },{
          title: "50% Benefits Limit:",
          key: :promotion304050Trigger50,
          value: ch.promotion304050Trigger50 || 500.0,
          type: :currency,
          input_accessory: :done,
          done_action: default_done_action
        }]
      },{
        title: "30th Anniversary Promotion:",
        rows: [{
          title: "Enable?",
          key: :promotion30405060,
          value: (ch.promotion30405060.nil?) ? false : ch.promotion30405060.to_bool,
          type: :switch,
        },{
          title: "60% Benefits Limit:",
          key: :promotion304050Trigger60,
          value: (ch.promotion304050Trigger60.nil?) ? 600.0 : ch.promotion304050Trigger60,
          type: :currency,
          input_accessory: :done,
          done_action: default_done_action
        }]
      }]
    }
  end

  def build_form
    return Formotion::Form.new() if ch.nil?
    Formotion::Form.new(form_data)
  end

  def init
    super.initWithForm(build_form)
  end

  def default_done_action
    -> { update_and_save_hostess }
  end

  def named_title
    return 'Home Show' if ch.nil? || ch.first_name.nil?

    t = "#{ch.first_name}'s Home Show"
    t << " on #{ch.createdDate.short_date}" if Device.ipad?
    t
  end

  def ch
    Hostesses.shared_hostess.current_hostess
  end
end
