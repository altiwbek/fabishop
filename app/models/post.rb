class Post < ApplicationRecord
  extend Mobility
  translates :title, :subtitle, :excerpt

  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :author, class_name: "User", optional: true

  has_rich_text :body
  has_one_attached :cover

  validates :title, presence: true

  scope :published, -> { where(published: true).where.not(published_at: nil) }
  scope :recent,    -> { order(published_at: :desc, created_at: :desc) }

  before_validation :set_published_at, if: -> { published? && published_at.blank? }

  def to_s = title

  def to_param = slug

  def reading_minutes
    words = body.to_plain_text.split.size
    [ (words / 200.0).ceil, 1 ].max
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  private

  def set_published_at
    self.published_at = Time.current
  end
end
