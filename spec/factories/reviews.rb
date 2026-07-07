FactoryBot.define do
  factory :review do
    association :product
    author_name { "Jane Reviewer" }
    rating { 5 }
    body { "Really solid product, would buy again." }
    approved { false }
  end
end
