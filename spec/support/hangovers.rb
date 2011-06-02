def summary_categories
  categories = []
  Hangover::TIME_PERIODS.each do |time_period|
    categories << "of_the_#{time_period}".to_sym
  end
  categories.unshift(Hangover::EXTRA_SUMMARY_CATEGORIES.first)
  categories << Hangover::EXTRA_SUMMARY_CATEGORIES.last
  categories
end

module HangoverExampleHelpers
  def join_parent_selector
    parent_selector.join(" ")
  end
end

