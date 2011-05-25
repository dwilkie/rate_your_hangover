Factory.define :user do |f|
end

Factory.define :hangover do |f|
  f.association :user
end

Factory.define :hangover_vote, :class => Vote do |f|
  f.association :user
  f.association :voteable, :factory => :hangover
end

