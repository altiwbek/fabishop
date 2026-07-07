module ProductsHelper
  PLACEHOLDER = "/molla/assets/images/demos/demo-3/products/product-1.jpg".freeze

  # Returns a URL for a product's image (nth attached image), falling back to a
  # placeholder so grids never show a broken image.
  def product_image_url(product, index: 0)
    if product.images.attached? && product.images[index]
      url_for(product.images[index])
    else
      PLACEHOLDER
    end
  end

  def product_has_second_image?(product)
    product.images.attached? && product.images.size > 1
  end

  def star_rating(value, reviews_count = nil)
    percent = (value.to_f / 5.0 * 100).round
    content_tag(:div, class: "ratings-container") do
      concat(content_tag(:div, class: "ratings") do
        content_tag(:div, "", class: "ratings-val", style: "width: #{percent}%;")
      end)
      if reviews_count
        concat(content_tag(:span, "( #{reviews_count} Reviews )", class: "ratings-text"))
      end
    end
  end

  def price_tag(product)
    if product.on_sale?
      content_tag(:div, class: "product-price") do
        concat content_tag(:span, number_to_currency(product.compare_at_price), class: "old-price")
        concat content_tag(:span, number_to_currency(product.price), class: "new-price")
      end
    else
      content_tag(:div, number_to_currency(product.price), class: "product-price")
    end
  end
end
