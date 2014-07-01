class GenieProcessorStylesheet < RubyMotionQuery::Stylesheet
  def root_view(st)
    st.background_color = color.white
  end

  def container(st)
    st.frame = {
      l: 10,
      fr: 10,
      h: 320,
      centered: :vertical
    }
  end

  def small_stars(st)
    st.image = image.resource('genie_star_small_textured')
    st.frame = image_frame
  end

  def small_stars2(st)
    st.image = image.resource('genie_star_small_solid')
    st.frame = image_frame
  end

  def big_stars(st)
    st.image = image.resource('genie_star_big')
    st.frame = image_frame
  end

  def wand(st)
    st.image = image.resource('genie_wand')
    st.frame = {l: 0, t:0, w: 320, h: 256, centered: :horizontal}
  end

  def working_magic(st)
    st.text = "Working Our Magic..."
    st.frame = {l: 0, bp: 0, fr:0, h: 20}
    st.text_alignment = :center
  end

  def progress(st)
    st.frame = {l: 0, bp: 15, fr:0, h: 10}
  end

  def image_frame
    {l:94, t:0, w:175, h:175}
  end
end
