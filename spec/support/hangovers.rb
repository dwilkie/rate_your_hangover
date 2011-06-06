def rate_it_link_text
  I18n.t('hangover.rate_it')
end

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
  def have_parent_selector(options = {})
    xpath = parent_selector.join("/")
    xpath = ".//#{xpath}" unless xpath[0..2] == ".//"
    have_selector(:xpath, xpath, options)
  end
end

