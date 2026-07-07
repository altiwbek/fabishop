FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    product_name { "Sample Item" }
    quantity   { 1 }
    unit_price { 9.99 }
  end
end
