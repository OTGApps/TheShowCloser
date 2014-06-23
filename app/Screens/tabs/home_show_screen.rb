class HomeShowScreen < Formotion::FormController
  include BW::KVO
  include ProMotion::ScreenModule

  def viewDidLoad
    super
    App.notification_center.observe "PickedHostessNotification" do |notification|
      ap "PickedHostessNotification"
      ap Hostesses.shared_hostess.current_hostess
      reinit
    end
  end

  def reinit
    self.form = build_form
    self.form.controller = self

    self.title = 'Home Show'
    self.navigationController.tabBarItem.title = "Show"
    self.navigationController.tabBarItem.image = UIImage.imageNamed('homeshow')

    set_nav_bar_button :left, {
      title: "Hostesses",
      system_item: :reply,
      action: :show_all_hostesses
    }

    # Listen for hostess changes
    observe_switches
  end

  def show_all_hostesses
    App.delegate.slide_menu.show(:right)
    unobserve_all
    Hostesses.shared_hostess.current_hostess = nil
  end

  def update_and_save_hostess(key = nil)
    return if Hostesses.shared_hostess.current_hostess.nil?
    ap 'Saving Hostess Data'

    serialized = form.render
    serialized[:created_date] = Time.at(serialized[:created_date])
    serialized[:jewelry_percentage] = serialized[:jewelry_percentage].to_i

    # Floatify
    [:tax_rate, :shipping, :show_total, :addtl_discount, :addtl_charge].each do |sym|
      serialized[sym] = "0" if serialized[sym].is_a?(String) && serialized[sym].empty?
      serialized[sym] = BigDecimal.new(serialized[sym]).to_f
    end

    ap serialized

    Hostesses.shared_hostess.current_hostess.set_and_save(serialized)
  end

  def observe_switches
    return if Hostesses.shared_hostess.current_hostess.nil?

    # Observe all switches in the form.
    self.form.sections.each_with_index do |s, si|
      s.rows.each_with_index do |r, ri|
        if r.type == :switch
          observe(self.form.sections[si].rows[ri], "value") do |old_value, new_value|
            update_and_save_hostess
          end
        end
      end
    end
  end

  def form_data
    ch = Hostesses.shared_hostess.current_hostess
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
          title: "Notes:",
          key: :notes,
          type: :text,
          value: ch.notes,
          input_accessory: :done,
          done_action: default_done_action
        }]
      },{
        title: "Hostess Benefits:",
        rows: [{
          title: "Free Jewelry (%)",
          key: :jewelry_percentage,
          type: :picker,
          items: ['20', '30', '40', '50'],
          value: ch.jewelryPercentage.to_s,
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
          value: ch.taxEnabled
        },{
          title: "Tax Rate (%)",
          key: :tax_rate,
          type: :number,
          value: ch.tax_rate,
          input_accessory: :done,
          done_action: default_done_action
        },{
          title: "Hostess Shipping",
          key: :shipping,
          type: :currency,
          input_accessory: :done,
          value: ch.shipping_rate,
          done_action: default_done_action
        },{
          title: "Tax Shipping?",
          key: :tax_shipping,
          type: :switch,
          value: ch.taxShipping
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
      }]
    }
  end

  def build_form
    return Formotion::Form.new() if Hostesses.shared_hostess.current_hostess.nil?
    Formotion::Form.new(form_data)
  end

  def init
    super.initWithForm(build_form)
  end

  def default_done_action
    -> { update_and_save_hostess }
  end
end
