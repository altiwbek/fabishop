class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :product_name, presence: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }

  def line_total = unit_price * quantity
end
