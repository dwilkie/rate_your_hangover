Factory.define :user do |f|
  f.sequence(:email) {|n| "hangover#{n}@example.com" }
  f.password "foobar"
  f.password_confirmation "foobar"
end

Factory.define :hangover do |f|
  f.association :user
end

Factory.define :hangover_vote, :class => Vote do |f|
  f.association :user
  f.association :voteable, :factory => :hangover
end

