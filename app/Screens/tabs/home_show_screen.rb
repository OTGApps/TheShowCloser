class HomeShowScreen < PM::FormotionScreen
  title "Homeshow"
  tab_bar_item icon: "tab_homeshow", title: "Homeshow"

  def on_load

  end

  def on_appear

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
