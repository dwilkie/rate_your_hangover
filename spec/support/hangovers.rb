def caption_titles
  hangover = Factory.build(:hangover)
  titles = []
  titles << hangover.build_caption(Hangover::EXTRA_SUMMARY_CATEGORIES.first)
  Hangover::TIME_PERIODS.each do |time_period|
    titles << hangover.build_caption(time_period)
  end
  titles << hangover.build_caption(Hangover::EXTRA_SUMMARY_CATEGORIES.last)
  titles
end

