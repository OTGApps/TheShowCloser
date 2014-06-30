class GenieProcessorStylesheet < RubyMotionQuery::Stylesheet
  def root_view(st)
    st.background_color = color.white
  end

  def small_stars(st)
    st.image = image.resource('genie_star_small_textured')
    st.frame = {l: 104, t: image_top, w: 175, h: 175}
  end

  def small_stars2(st)
    st.image = image.resource('genie_star_small_solid')
    st.frame = {l: 104, t: image_top, w: 175, h: 175}
  end

  def big_stars(st)
    st.image = image.resource('genie_star_big')
    st.frame = {l: 104, t: image_top, w: 175, h: 175}
  end

  def wand(st)
    st.image = image.resource('genie_wand')
    st.frame = {l: 0, t: image_top, w: 320, h: 256, centered: :horizontal}
  end

  def working_magic(st)
    st.text = "Working Our Magic..."
    st.frame = {l: 5, t: 346, w: 200, h: 20}
    st.centered = :horizontal
    st.text_alignment = :center
  end

  def progress(st)

  end

  def image_top; 90; end

end
