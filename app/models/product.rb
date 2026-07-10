class Product < ApplicationRecord
  extend Mobility
  translates :name, :subtitle

  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :category, counter_cache: true
  belongs_to :brand, optional: true, counter_cache: true

  has_many :collection_products, dependent: :destroy
  has_many :collections, through: :collection_products
  has_many :reviews, dependent: :destroy

  has_rich_text :description
  has_many_attached :images

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :published,    -> { where(published: true) }
  scope :featured,     -> { where(featured: true) }
  scope :new_arrivals, -> { where(new_arrival: true) }
  scope :on_sale,      -> { where(on_sale: true) }
  scope :in_stock,     -> { where("stock > 0") }
  scope :out_of_stock, -> { where(stock: 0) }
  scope :low_stock,    ->(threshold = 5) { where("stock > 0 AND stock <= ?", threshold) }
  scope :recent,       -> { order(created_at: :desc) }
  scope :popular,      -> { order(views_count: :desc) }
  scope :top_rated,    -> { order(rating: :desc, reviews_count: :desc) }

  # Search matches the SKU plus translated name/subtitle in ANY locale (the whole
  # translations jsonb is scanned as text), so a query hits regardless of which
  # language the shopper is browsing in.
  scope :search, ->(q) {
    return all if q.blank?
    like = "%#{sanitize_sql_like(q.to_s)}%"
    where("products.translations::text ILIKE :q OR products.sku ILIKE :q", q: like)
  }

  before_validation :set_published_at, if: -> { published? && published_at.blank? }

  def to_s = name

  def to_param = slug

  def on_sale?
    on_sale && compare_at_price.present? && compare_at_price > price
  end

  def discount_percent
    return 0 unless on_sale?
    (((compare_at_price - price) / compare_at_price) * 100).round
  end

  def in_stock?  = stock.positive?
  def low_stock?(threshold = 5) = stock.positive? && stock <= threshold

  def primary_image
    images.attached? ? images.first : nil
  end

  # Star width percentage used by the Molla `.ratings-val` bar.
  def rating_percent
    ((rating.to_f / 5.0) * 100).round
  end

  def recalculate_rating!
    approved = reviews.approved
    update_columns(
      rating: approved.average(:rating)&.round(2) || 0,
      reviews_count: approved.count
    )
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  private

  def set_published_at
    self.published_at = Time.current
  end
end
