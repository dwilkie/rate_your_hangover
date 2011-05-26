def summary_categories
  hangover = Hangover.new
  categories = []
  categories << Hangover::EXTRA_SUMMARY_CATEGORIES.first
  Hangover::TIME_PERIODS.each do |time_period|
    categories << hangover.build_caption(time_period).gsub(/""/, "")
  end
  categories << Hangover::EXTRA_SUMMARY_CATEGORIES.last
  categories
end

