class Brand < ApplicationRecord
  extend Mobility
  translates :name, :description

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :products, dependent: :nullify
  has_one_attached :logo

  validates :name, presence: true

  scope :ordered, -> { order(:position).order_by_translation(:name) }

  def to_s = name

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
