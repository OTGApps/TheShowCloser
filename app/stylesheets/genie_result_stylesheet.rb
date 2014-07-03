class GenieResultStylesheet < ApplicationStylesheet
  def web_view(st)
    st.background_color = color.white
  end

  def apply_button(st)
    st.frame = {l: 0, fr:0, h: 60, fb: 0}

    st.text = 'Apply Changes'
    st.color = color.white
    st.background_color = color.purple
  end
end
