class GenieResultScreen < PM::WebScreen
  attr_accessor :results, :info

  title "Jewelry Genie Results"

  def on_load
    self.navigationItem.setHidesBackButton(true) # Hide the back button
    set_nav_bar_button :right, system_item: :stop, action: :cancel

    rmq.stylesheet = GenieResultStylesheet

    ap @results
    ap @info
  end

  def will_appear
    @view_set_up ||= begin
      rmq(web).apply_style :web_view

      apply_button = rmq(self.view).append(UIButton, :apply_button).on(:tap) do |sender|
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

  def cancel
    self.navigationController.dismissModalViewControllerAnimated(true)
  end

  def apply
    ap "Applying"

    @results[:combo].each_with_index do |h_f, i|

    end


    cancel
  end

  def ch
    Hostesses.shared_hostess.current_hostess
  end

end
