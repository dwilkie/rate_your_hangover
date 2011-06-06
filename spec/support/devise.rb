RSpec.configure do |config|
  [:controller, :view].each do |type|
    config.include Devise::TestHelpers, :type => type
  end
end

