FactoryBot.define do
  factory :collection_product do
    association :collection
    association :product
  end
end
