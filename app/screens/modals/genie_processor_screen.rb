class GenieProcessorScreen < PM::Screen
  attr_accessor :should_break, :brain
  title "Calculating Best Deal..."

  def on_load
    @should_break = false

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

    @brain = BrainGenie.new
    @brain.h = Hostesses.shared_hostess.current_hostess.copy
    puts "Hostess"
    ap @brain.h
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
    key = 'rotation_animation'
    @small_stars.get.layer.addAnimation(rotation_animation, forKey:key)

    rotation_animation.duration = 4.25
    @small_stars2.get.layer.addAnimation(rotation_animation, forKey:key)

    rotation_animation.duration = 8.25
    @big_stars.get.layer.addAnimation(rotation_animation, forKey:key)
  end

  def cancel
    p 'Canceling process.'
    @should_break = true
    @brain = nil
    close
  end

  # Determine if the free/half_price combo should be processed or not
  def should_process?(combo)
    half_count = combo.select{|c| c == :half}.count
    retail = @brain.h.showTotal
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

    @jewelry_set = []

    # Loop through all the free jewelry and store copies of the objects
    ch.items.each do |item|
      item.qtyFree.to_i.times do |loop|
        @jewelry_set << item.copy
      end
      item.qtyHalfPrice.to_i.times do |loop|
        @jewelry_set << item.copy
      end
    end
    # puts "Jewelry Set:"
    # ap @jewelry_set

    Dispatch::Queue.concurrent('com.mohawkapps.theshowcloser.genie').async do
      start_time = NSDate.date
      p "Wishlist Array #{@jewelry_set}"

      # Now that we have the array, we need to loop through every combination
      # that exists and calculate which is the cheapest or leaves the least
      # amount of overage

      n = @jewelry_set.count
      p 'A'
      p n

      combinations = [:free, :half].cartesian_power(n)
      p 'B'
      ap @brain.h.showTotal
      # Remove all combos that are not allowed
      combinations = combinations.reject do |c|
        half_count = c.select{|i| i == :half}.count
        (half_count > 8) || (half_count > 6 && @brain.h.showTotal < 500) || (half_count > 4 && @brain.h.showTotal < 300)
      end
      p 'C'
      # Limit total calculations to 5000
      combinations = combinations.sample(5000)
      p 'D'

      total_combos = combinations.count
      p "Total combos: #{total_combos}"

      combinations.each_with_index do |combo, i|
        break if @should_break == true
        # Here's where the magic happens!

        # Set the brain's "fake" data
        if @brain.jewelry_combo.nil?
          @brain.jewelry_combo = {
            combo: combo,
            items: @jewelry_set
          }
        else
          @brain.jewelry_combo[:combo] = combo
        end

        # Get the totals
        @b_dict = @brain.calculate
        ap @b_dict

        Dispatch::Queue.main.sync do
          @progress.setProgress((i + 1) / total_combos.to_f, animated:false)
        end

        # # Compare it to the best combo
        if @best_combo.nil? || @b_dict[:totalDue] < @best_combo[:total_cost]
          @best_combo = @brain.jewelry_combo.merge({
            free_left: @b_dict[:totalHostessBenefitsSix] - @b_dict[:freeTotal],
            total_cost: @b_dict[:totalDue]
          })
        end

      end

      # Set the brain back to the real data
      if @should_break == false
        p 'Best Combo:'
        p @best_combo.inspect

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
            results: @best_combo,
            info: timer_info
          )
        end
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
