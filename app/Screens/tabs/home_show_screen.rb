class HomeShowScreen < PM::FormotionScreen
  title "Homeshow"
  tab_bar_item icon: "tab_homeshow", title: "Homeshow"

  def on_load
    set_nav_bar_button :left, {
      title: "Hostesses",
      system_item: :reply,
      action: :show_hostesses
    }

    # Listen for hostess changes
    App.notification_center.observe "PickedHostessNotification" do |notification|
      ap Hostesses.shared_hostess.current_hostess
      reinit
    end
  end

  def reinit
    self.title = "#{Hostesses.shared_hostess.current_hostess.name}'s Homeshow"
  end

  def show_hostesses
    App.delegate.slide_menu.show(:right)
    Hostesses.shared_hostess.current_hostess = nil
  end

  def on_submit(_form)

  end

  def table_data
    {
      sections: [{
        title: "Hostess's Show:",
        rows: [{
          title: "Total",
          key: :show_total,
          type: :currency,
          input_accessory: :done
        },{
          title: "Earned Bonus 1:",
          key: :show_bonus_1,
          type: :switch
        },{
          title: "Earned Bonus 2:",
          key: :show_bonus_2,
          type: :switch
        }]
      },{
        title: "About The Show:",
        rows: [{
          title: "Date",
          key: :show_date,
          type: :date,
          format: :medium,
          input_accessory: :done
        },{
          title: "Notes:",
          key: :show_notes,
          type: :text,
          input_accessory: :done
        }]
      }]
    }
  end

end
