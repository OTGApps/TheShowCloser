class GenieResultScreen < PM::WebScreen
  attr_accessor :results, :info

  title "Jewelry Genie Results"

  def on_load
    self.navigationItem.setHidesBackButton(true) # Hide the back button
    set_nav_bar_button :right, system_item: :stop, action: :close_modal

    rmq.stylesheet = GenieResultStylesheet
  end

  def will_appear
    Flurry.logEvent("GENIE_GOT_SUGGESTIONS") unless Device.simulator?
    @view_set_up ||= begin
      rmq(web).apply_style :web_view
      rmq(self.view).append(UIButton, :apply_button).on(:tap) do |sender|
        apply
      end
    end
  end

  def content
    html = File.read(File.join(App.resources_path, "GenieTemplate.html"))
    html.sub!('[[[PERMUTATIONS]]]', @info[:valid_permutations_count].to_s)
    html.sub!('[[[TIME]]]', @info[:time_to_complete].round(2).to_s)
    html.sub!('[[[JEWELRY]]]', half_price_item_list)
    html.sub!('[[[RECEIPT_TOTAL]]]', Dolarizer.d(@results[:total_cost]))
    html
  end

  def half_price_item_list
    html = ''
    @results[:combo].each_with_index do |h_f, i|
      if h_f == :half
        html << "<li>Item: #{@results[:items][i].item}<br /><small>#{@results[:items][i].name}</small></li>"
      end
    end
    html.empty? ? "<li>No changes.</li>" : html
  end

  def close_modal(automatic = false)
    unless Device.simulator?
      Flurry.logEvent("GENIE_DENIED_SUGGESTIONS") unless automatic
    end
    self.navigationController.dismissModalViewControllerAnimated(true)
  end

  def apply
    Flurry.logEvent("GENIE_TOOK_SUGGESTIONS") unless Device.simulator?

    # Reset all the items to zero
    ch.items.each do |i|
      ch.set_halfprice(i.item, 0, false)
      ch.set_free(i.item, 0, false)
    end

    # Apply the changes to the wishlist
    @results[:combo].each_with_index do |h_f, i|
      changing_item = @results[:items][i]
      current_item = ch.item(changing_item.item)

      if h_f == :free
        ch.set_free(current_item.item, (current_item.qtyFree + 1), false)
      elsif h_f == :half # Explicit FTW!
        ch.set_halfprice(current_item.item, (current_item.qtyHalfPrice + 1), false)
      end
    end
    App.notification_center.post 'ReloadJewelryTableNotification'

    close_modal(true)
  end

  def ch
    Hostesses.shared_hostess.current_hostess
  end

  def shouldAutorotate
    false
  end

  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown
  end

  def preferredInterfaceOrientationForPresentation
    UIInterfaceOrientationPortrait
  end

end
