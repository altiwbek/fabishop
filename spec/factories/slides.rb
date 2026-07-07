FactoryBot.define do
  factory :slide do
    sequence(:title) { |n| "Slide #{n}" }
  end
end
