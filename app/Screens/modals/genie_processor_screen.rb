class GenieProcessorScreen < PM::Screen
  title "Calculating Best Deal..."

  def on_load
    set_nav_bar_button :right, system_item: :stop, action: :cancel

    rmq.stylesheet = GenieProcessorStylesheet
    rmq(self.view).apply_style :root_view

    container = rmq.append(UIView, :container)

    @small_stars = container.append(UIImageView, :small_stars)
    @small_stars_2 = container.append(UIImageView, :small_stars2)
    @big_stars = container.append(UIImageView, :big_stars)
    container.append(UIImageView, :wand)

    container.append(UILabel, :working_magic)
    @progress = container.append(UIProgressView.alloc.initWithProgressViewStyle(UIProgressViewStyleDefault), :progress)
    @progress.get.setProgress(0.5, animated:true)
  end

  def will_appear
    @view_set_up ||= begin
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
    @small_stars_2.get.layer.addAnimation(rotation_animation, forKey:"rotation_animation")

    rotation_animation.duration = 8.25
    @big_stars.get.layer.addAnimation(rotation_animation, forKey:"rotation_animation")
  end

  def cancel
    ap "Canceling process."
    close
  end
end
