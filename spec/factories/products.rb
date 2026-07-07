FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    price { 19.99 }
    stock { 10 }
    published { true }
    association :category
  end
end
