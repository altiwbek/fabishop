class Slide < ApplicationRecord
  extend Mobility
  translates :title, :subtitle, :price_label, :button_label

  has_one_attached :image

  validates :title, presence: true

  scope :ordered, -> { order(:position, :id) }
  scope :active,  -> { where(active: true) }

  def to_s = title

  # A slide's title may contain a manual line break marker "|" to control wrapping.
  def title_html
    ERB::Util.html_escape(title).gsub("|", "<br>").html_safe
  end
end
