class RecentlyViewedController < StorefrontController
  # Lazy-loaded Turbo Frame content on the product page.
  def show
    exclude = Product.friendly.find(params[:exclude]) if params[:exclude].present?
    @products = recently_viewed_products(exclude: exclude).first(4)
    render layout: false
  end
end
