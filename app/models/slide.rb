class Slide < ApplicationRecord
  extend Mobility
  translates :title, :subtitle, :price_label, :button_label

  has_one_attached :image do |attachable|
    # Hero banner — keep it large but capped and metadata-stripped.
    attachable.variant :hero, resize_to_limit: [ 1920, 900 ], saver: { quality: 80, strip: true }, preprocessed: true
  end

  validates :title, presence: true

  scope :ordered, -> { order(:position, :id) }
  scope :active,  -> { where(active: true) }

  def to_s = title

  # A slide's title may contain a manual line break marker "|" to control wrapping.
  def title_html
    ERB::Util.html_escape(title).gsub("|", "<br>").html_safe
  end
end
