FactoryBot.define do
  factory :order do
    first_name { "John" }
    last_name  { "Doe" }
    email      { "john@example.com" }
    address    { "123 Main St" }
    city       { "Springfield" }
    # number and token are assigned automatically before validation.
  end
end
