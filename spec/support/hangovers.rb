TRANSLATIONS = {
  :rate_it => "hangover.rate_it",
  :you_rate_it => "hangover.you_rate_it",
  :got_a_hangover => "hangover.got_one",
  :sign_up => "devise.registrations.sign_up",
  :sign_in => "devise.sessions.sign_in",
  :display_name => Proc.new { User.human_attribute_name(:display_name) },
  :email => Proc.new { User.human_attribute_name(:email) },
  :password => Proc.new { User.human_attribute_name(:password) },
  :password_confirmation => Proc.new { User.human_attribute_name(:password_confirmation) },
  :signed_up => "devise.registrations.signed_up",
  :signed_in => "devise.sessions.signed_in",
  :cant_be_blank => "errors.messages.blank",
  :forgot_password => "devise.passwords.forgot_password",
  :incorrect_credentials => "devise.failure.invalid"
}

def spec_translate(key)
  translation = TRANSLATIONS[key]
  if translation.is_a?(String)
    I18n.t(translation)
  elsif translation.is_a?(Proc)
    translation.call
  else
    raise "Translation '#{key}' not found. Add it to #{__FILE__}"
  end
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

