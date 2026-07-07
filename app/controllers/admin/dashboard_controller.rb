class Admin::DashboardController < Admin::BaseController
  def index
    @page_title = "Dashboard"

    @stats = {
      products: Product.count,
      published: Product.published.count,
      out_of_stock: Product.out_of_stock.count,
      low_stock: Product.low_stock.count,
      categories: Category.count,
      collections: Collection.count,
      brands: Brand.count,
      posts: Post.count,
      pending_reviews: Review.where(approved: false).count
    }

    @inventory_value = Product.sum("price * stock")
    @orders_count = Order.count
    @pending_orders = Order.pending.count
    @revenue = Order.where.not(status: :cancelled).sum(:total)
    @recent_orders = Order.recent.limit(5)
    @recent_products = Product.includes(:category).order(created_at: :desc).limit(6)
    @low_stock_products = Product.low_stock.includes(:category).order(:stock).limit(6)
    @pending_reviews = Review.where(approved: false).includes(:product).order(created_at: :desc).limit(5)
    @top_viewed = Product.published.popular.limit(5)

    # Products per category, for the bar chart.
    @category_breakdown = Category.roots.ordered.map { |c| [ c.name, c.products_count ] }
                                  .reject { |_, count| count.zero? }
    @max_category_count = (@category_breakdown.map(&:last).max || 1)
  end
end
