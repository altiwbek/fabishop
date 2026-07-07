class Review < ApplicationRecord
  belongs_to :product

  validates :author_name, presence: true
  validates :rating, numericality: { only_integer: true, in: 1..5 }
  validates :body, presence: true

  scope :approved, -> { where(approved: true) }
  scope :recent,   -> { order(created_at: :desc) }

  after_save :refresh_product_rating
  after_destroy :refresh_product_rating

  def rating_percent
    (rating.to_f / 5.0 * 100).round
  end

  private

  def refresh_product_rating
    product.recalculate_rating!
  end
end
