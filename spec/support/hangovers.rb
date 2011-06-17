TRANSLATIONS = {
  :rate_it => "hangover.rate_it",
  :sober => "hangover.sober",
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
  :incorrect_credentials => "devise.failure.invalid",
  :new_hangover => "hangover.new",
  :create_hangover => "hangover.create",
  :title => Proc.new { Hangover.human_attribute_name(:title) },
  :image => Proc.new { Hangover.human_attribute_name(:image) },
  :hangover_created => "hangover.created",
  :sign_in_to_rate_it => "hangover.sign_in_to_rate_it",
  :vote => "vote",
  :caption => "hangover.caption",
  :sign_up_or_sign_in_to_continue => "devise.failure.unauthenticated"
}

def spec_translate(key, options = {})
  translation = TRANSLATIONS[key]
  if translation.is_a?(String)
    I18n.t(translation, options)
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

def image_fixture_path
  File.join(fixture_path, 'images', 'rails.png')
end

module HangoverExampleHelpers
  def have_parent_selector(options = {})
    xpath = parent_selector.join("/")
    xpath = ".//#{xpath}" unless xpath[0..2] == ".//"
    have_selector(:xpath, xpath, options)
  end
end

