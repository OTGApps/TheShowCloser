class ApplicationStylesheet < RubyMotionQuery::Stylesheet
  def application_setup
    color.add_named :purple, "#7B4289".to_color
  end
end
