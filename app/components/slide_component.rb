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
end
