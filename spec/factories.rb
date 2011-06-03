Factory.define :user do |f|
end

Factory.define :registered_user, :parent => :user do |f|
  f.display_name "Dave"
  f.sequence(:email) {|n| "user#{n}@example.com" }
  f.password "secret"
end

Factory.define :hangover do |f|
  f.title "Alan"
  f.association :user
end

Factory.define :hangover_vote, :class => Vote do |f|
  f.association :user
  f.association :voteable, :factory => :hangover
end

