require File.expand_path("support/uploader_helpers", File.dirname(__FILE__))
include UploaderHelpers

Factory.define :unregistered_user, :class => User do |f|
end

Factory.define :user, :parent => :unregistered_user do |f|
  f.display_name "Dave"
  f.sequence(:email) {|n| "user#{n}@example.com" }
  f.password "secret"
end

Factory.define :hangover_without_image, :class => Hangover do |f|
  f.title "Alan"
  f.association :user, :factory => :user
  # 'key' is a lazy attribute https://github.com/thoughtbot/factory_girl/tree/v1.3.3
  f.key { UploaderHelpers.sample_key(:subject => Hangover) }
end

Factory.define :hangover, :parent => :hangover_without_image do |f|
  f.image File.open(
    File.join(Rails.root, 'spec', 'fixtures', 'images', 'rails.png')
  )
end

Factory.define :hangover_vote, :class => Vote do |f|
  f.association :user
  f.association :voteable, :factory => :hangover
end

Factory.define :notification do |f|
  f.association :user
end

Factory.define :read_notification, :parent => :notification do |f|
  f.read_at Time.now
end

