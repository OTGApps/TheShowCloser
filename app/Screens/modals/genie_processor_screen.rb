class GenieProcessorScreen < PM::Screen
  title "Calculating Best Deal..."

  def on_load
    set_nav_bar_button :right, system_item: :stop, action: :cancel
  end

  def will_appear
    @view_set_up ||= begin
      self.view.backgroundColor = UIColor.whiteColor
    end
  end

  def cancel
    ap "Canceling process."
    close
  end
end
