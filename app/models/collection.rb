class Collection < ApplicationRecord
  extend Mobility
  translates :name, :subtitle, :description

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :collection_products, -> { order(:position) }, dependent: :destroy
  has_many :products, through: :collection_products

  has_one_attached :cover

  validates :name, presence: true

  scope :ordered, -> { order(:position).order_by_translation(:name) }
  scope :active, -> { where(active: true) }
  scope :featured, -> { where(featured: true) }

  def to_s = name

  def published_products
    products.published
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
