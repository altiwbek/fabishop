# frozen_string_literal: true

# Renders a single hero slide inside the storefront intro slider.
# Use with a collection: `render(SlideComponent.with_collection(@slides))`.
class SlideComponent < ViewComponent::Base
  def initialize(slide:)
    @slide = slide
  end

  private

  attr_reader :slide

  def button_url
    slide.button_url.presence || helpers.products_path
  end

  # Falls back to a placeholder when a slide has no image attached, so the
  # hero never renders a broken image or raises on an unattached attachment.
  def image_url
    helpers.slide_image_url(slide)
  end
end
