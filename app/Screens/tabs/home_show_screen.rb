class HomeShowScreen < PM::FormotionScreen
  include BW::KVO

  title "Home Show"
  # tab_bar_item icon: "tab_homeshow", title: "Home Show"

  def on_load
    set_nav_bar_button :left, {
      title: "Hostesses",
      system_item: :reply,
      action: :show_hostesses
    }

    # Listen for hostess changes
    App.notification_center.observe "PickedHostessNotification" do |notification|
      ap "PickedHostessNotification"
      ap Hostesses.shared_hostess.current_hostess
      reinit
    end
    observe_switches
  end

  def reinit
    # ap get_title
    # self.title = "#{Hostesses.shared_hostess.current_hostess.name}'s Home Show"
    # self.tabBarItem.title = "Home Show"
    # resolve_title
    update_table_data
  end

  def show_hostesses
    App.delegate.slide_menu.show(:right)
    Hostesses.shared_hostess.current_hostess = nil
  end

  def done(key = nil)
    return if Hostesses.shared_hostess.current_hostess.nil?
    ap 'Saving Hostess Data'

    serialized = form.render
    ap serialized

    ch = Hostesses.shared_hostess.current_hostess

    case key
    when :show_total
      ch.show_total = serialized[:show_total]
    when :show_date
      ch.show_date = Time.at(serialized[:show_date])
    when :show_notes
      ch.show_notes = serialized[:show_notes]
    when :show_bonus_1
      ch.bonus_1 = serialized[:show_bonus_1].to_bool
    when :show_bonus_2
      ch.bonus_2 = serialized[:show_bonus_2].to_bool
    end

    ch.save
  end

  def observe_switches
    row1 = @form.sections[0].rows[1]
    row2 = @form.sections[0].rows[2]

    ap "Observing Switches"
    ap row1

    observe(row1, "value") do |old_value, new_value|
      ap new_value
      done(:bonus_1)
    end

    observe(row2, "value") do |old_value, new_value|
      ap new_value
      done(:bonus_1)
    end
  end


  def table_data
    {
      sections: [{
        title: "Hostess's Show:",
        rows: [{
          title: "Total",
          key: :show_total,
          type: :currency,
          value: (Hostesses.shared_hostess.current_hostess.nil?) ? 0 : Hostesses.shared_hostess.current_hostess.showTotal,
          input_accessory: :done,
          done_action: Proc.new{ done(:show_total) }
        },{
          title: "Earned Bonus 1:",
          key: :show_bonus_1,
          value: (Hostesses.shared_hostess.current_hostess.nil?) ? false : Hostesses.shared_hostess.current_hostess.bonus1.to_bool,
          type: :switch
        },{
          title: "Earned Bonus 2:",
          key: :show_bonus_2,
          value: (Hostesses.shared_hostess.current_hostess.nil?) ? false : Hostesses.shared_hostess.current_hostess.bonus2.to_bool,
          type: :switch
        }]
      },{
        title: "About The Show:",
        rows: [{
          title: "Hostess Name",
          key: :name,
          type: :string,
          value: (Hostesses.shared_hostess.current_hostess.nil?) ? '' : Hostesses.shared_hostess.current_hostess.name,
          input_accessory: :done,
          done_action: Proc.new{ done(:name) }
        }{
          title: "Date",
          key: :show_date,
          type: :date,
          format: :medium,
          value: (Hostesses.shared_hostess.current_hostess.nil?) ? 0 : Hostesses.shared_hostess.current_hostess.showDate.to_i,
          input_accessory: :done,
          done_action: Proc.new{ done(:show_date) }
        },{
          # TODO - Make this work
          title: "Notes:",
          key: :notes,
          type: :text,
          input_accessory: :done,
          done_action: Proc.new{ done(:notes) }
        }]
      },{
        title: "Hostess Benefits:",
        rows: [{
          title: "Free Jewelry",
          key: :jewelryPercentage,
          type: :string,
          value: (Hostesses.shared_hostess.current_hostess.nil?) ? 30 : Hostesses.shared_hostess.current_hostess.jewelryPercentage,
          input_accessory: :done,
          done_action: Proc.new{ done(:jewelryPercentage) }
        }{
          title: "Bonus Value",
          key: :bonusValue,
          type: :string,
          value: (Hostesses.shared_hostess.current_hostess.nil?) ? 50 : Hostesses.shared_hostess.current_hostess.bonusValue,
          input_accessory: :done,
          done_action: Proc.new{ done(:bonusValue) }
        },{
          title: "Promotional Extra Bonus",
          key: :bonusExtra,
          type: :text,
          input_accessory: :done,
          value: (Hostesses.shared_hostess.current_hostess.nil?) ? 0 : Hostesses.shared_hostess.current_hostess.bonusExtra,
          done_action: Proc.new{ done(:bonusExtra) }
        }]
      }]
    }
  end

end