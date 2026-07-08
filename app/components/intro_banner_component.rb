# frozen_string_literal: true

# Renders a single collection banner in the storefront hero's intro-banners
# column. Use with a collection:
#   render(IntroBannerComponent.with_collection(collections))
class IntroBannerComponent < ViewComponent::Base
  # All banners share the demo image's wide aspect so uploaded covers of any
  # size crop to the same box and the three stacked banners match the slider.
  IMAGE_STYLE = "width:100%;aspect-ratio:37/12;object-fit:cover;"

  with_collection_parameter :collection

  # `collection_counter` is ViewComponent's 0-based index within the collection.
  def initialize(collection:, collection_counter: 0)
    @collection = collection
    @counter = collection_counter
  end

  private

  attr_reader :collection

  # Cycles through the three demo banner images when a collection has no cover.
  def fallback_image_path
    "/molla/assets/images/demos/demo-3/banners/banner-#{(@counter % 3) + 1}.jpg"
  end
end
