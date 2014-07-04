class GenieProcessorScreen < PM::Screen
  title "Calculating Best Deal..."

  def on_load
    set_nav_bar_button :right, system_item: :stop, action: :cancel

    rmq.stylesheet = GenieProcessorStylesheet
    rmq(self.view).apply_style :root_view

    container = rmq.append(UIView, :container)

    @small_stars = container.append(UIImageView, :small_stars)
    @small_stars2 = container.append(UIImageView, :small_stars2)
    @big_stars = container.append(UIImageView, :big_stars)
    container.append(UIImageView, :wand)

    container.append(UILabel, :working_magic)
    @progress = container.append(UIProgressView.alloc.initWithProgressViewStyle(UIProgressViewStyleDefault), :progress).get

    perform_calculations
  end

  def will_appear
    @view_set_up ||= begin
      [:small_stars, :small_stars2, :big_stars].each do |s|
        rmq(s).nudge(r: 30)
      end

      start_animating
    end
  end

  def start_animating
    rotation_transform = CATransform3DMakeRotation(1.0 * Math::PI / 2, 0, 0, 1.0)

    rotation_animation = CABasicAnimation.animationWithKeyPath('transform')
    rotation_animation.toValue = NSValue.valueWithCATransform3D(rotation_transform)
    rotation_animation.duration = 2.25
    rotation_animation.cumulative = true

    rotation_animation.repeatCount = Float::MAX
    @small_stars.get.layer.addAnimation(rotation_animation, forKey:"rotation_animation")

    rotation_animation.duration = 4.25
    @small_stars2.get.layer.addAnimation(rotation_animation, forKey:"rotation_animation")

    rotation_animation.duration = 8.25
    @big_stars.get.layer.addAnimation(rotation_animation, forKey:"rotation_animation")
  end

  def cancel
    p 'Canceling process.'
    Brain.app_brain.tmp_jewelry_combo = nil
    close
  end

  # Determine if the free/half_price combo should be processed or not
  def should_process?(combo, retail)
    half_count = combo.select{|c| c == :half}.count
    if (half_count > 8) || (half_count > 6 && retail < 500) || (half_count > 4 && retail < 300)
      # These combos break the rules of half price items.
      false
    else
      true
    end
  end

  def perform_calculations
    p 'Start Processing'

    @progress.setProgress(0.0, animated:false)

    jewelry_set = []
    costs = []
    total_cost_orig = Brain.app_brain.grandTotal

    # Loop through all the free jewelry and store copies of the objects
    ch.items.each do |item|
      item.qtyFree.to_i.times do |loop|
        jewelry_set << item.copy
      end
      item.qtyHalfPrice.to_i.times do |loop|
        jewelry_set << item.copy
      end
    end

    Dispatch::Queue.concurrent.async do
      start_time = NSDate.date
      p "Wishlist Array #{jewelry_set}"

      # Now that we have the array, we need to loop through every combination
      # that exists and calculate which is the cheapest or leaves the least
      # amount of overage

      n = jewelry_set.count

      total_retail = Brain.app_brain.totalRetail

      combinations = []
      [:free, :half].cartesian_power(n){ |l| combinations << l }
      combinations.select!{|c| should_process?(c, total_retail) }

      total_combos = combinations.count
      best_combo = false
      # p "Total combos: #{total_combos}"

      combinations.each_with_index do |combo, i|
        # Here's where the magic happens!

        # Set the brain's "fake" data
        if Brain.app_brain.tmp_jewelry_combo.nil?
          Brain.app_brain.tmp_jewelry_combo = {
            combo: combo,
            items: jewelry_set
          }
        else
          Brain.app_brain.tmp_jewelry_combo[:combo] = combo
        end

        # p "Processing Combo:"
        # p Brain.app_brain.tmp_jewelry_combo[:combo].inspect

        # Get the total price
        b_dict = Brain.app_brain.calculate
        free_left = b_dict[:totalHostessBenefitsSix] - b_dict[:freeTotal]
        total_cost = b_dict[:totalDue]

        # p "Free Left: #{free_left}"

        Dispatch::Queue.main.sync do
          @progress.setProgress((i + 1) / total_combos.to_f, animated:false)
        end

        # Compare it to the best combo
        # next if free_left > 5.0
        if !best_combo || total_cost < best_combo[:total_cost]
          best_combo = Brain.app_brain.tmp_jewelry_combo.merge({
            free_left: free_left,
            total_cost: total_cost,
            previous_total: total_cost_orig
          })
        end

      end

      # Set the brain back to the real data
      Brain.app_brain.tmp_jewelry_combo = nil

      p 'Best Combo:'
      p best_combo.inspect

      stop_time = NSDate.date
      execution_time_sec = stop_time.timeIntervalSinceDate(start_time)
      timer_info = {
        time_to_complete: execution_time_sec,
        valid_permutations_count: total_combos
      }
      # Flurry.logEvent("GENIE_FINISHED_WITH_TIME", withParameters:timer_info) unless BW.debug?

      Dispatch::Queue.main.sync do
        # Show the summary screen.
        open GenieResultScreen.new(
          external_links: false,
          results: best_combo,
          info: timer_info
        )
      end
    end
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
