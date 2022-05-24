module SearchesHelper

  def picker_wheel_iframe_src(search:)
    "https://pickerwheel.com/emb?choices=#{picker_wheel_choices(search:)}"
  end

  private
  def picker_wheel_choices(search:)
    search.picker_choices.map { |choice| CGI.escape(choice) }.join(',')
  end
end
