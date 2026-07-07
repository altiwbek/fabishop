class HomeController < StorefrontController
  def index
    @slides = Slide.active.ordered
    @featured_categories = Category.roots.ordered.limit(6)
    @new_products      = published_scope.new_arrivals.recent.limit(8).presence || published_scope.recent.limit(8)
    @featured_products = published_scope.featured.limit(8)
    @top_collections   = Collection.active.ordered.limit(3)
    @deal_product      = published_scope.on_sale.order(compare_at_price: :desc).first
    @posts             = Post.published.recent.limit(3)
    @brands            = Brand.ordered.limit(6)
  end

  private

  def published_scope
    Product.published.includes(:category, images_attachments: :blob)
  end
end
