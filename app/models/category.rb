class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :nullify
  has_many :products, dependent: :restrict_with_error

  has_one_attached :image

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:position, :name) }
  scope :roots, -> { where(parent_id: nil) }
  scope :featured, -> { where(featured: true) }

  def to_s = name

  # Products in this category *and* any of its child categories.
  def all_products
    Product.where(category_id: [ id, *children.ids ])
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
