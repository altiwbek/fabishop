class ProductsController < StorefrontController
  def index
    @products = filtered_scope
    @pagy, @products = pagy(@products)
    @categories = Category.roots.ordered
    @brands = Brand.ordered
  end

  def show
    @product = Product.published.friendly.find(params[:id])
    track_recently_viewed(@product)
    @product.increment!(:views_count)
    @reviews = @product.reviews.approved.recent
    @review = @product.reviews.new
    @related = Product.published
                      .where(category_id: @product.category_id)
                      .where.not(id: @product.id)
                      .includes(:category).limit(4)
  end

  private

  def filtered_scope
    scope = Product.published.includes(:category, :brand, images_attachments: :blob)
    scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?
    scope = scope.where(brand_id: params[:brand_id]) if params[:brand_id].present?
    scope = scope.on_sale if params[:on_sale].present?
    scope = scope.in_stock if params[:in_stock].present?
    scope = scope.search(params[:q]) if params[:q].present?
    scope = scope.where("price >= ?", params[:min_price]) if params[:min_price].present?
    scope = scope.where("price <= ?", params[:max_price]) if params[:max_price].present?
    sort(scope)
  end

  def sort(scope)
    case params[:sort]
    when "price_asc"  then scope.order(price: :asc)
    when "price_desc" then scope.order(price: :desc)
    when "rating"     then scope.top_rated
    when "popular"    then scope.popular
    when "name"       then scope.order(:name)
    else scope.recent
    end
  end
end
