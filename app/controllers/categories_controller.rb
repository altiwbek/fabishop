class CategoriesController < StorefrontController
  def index
    @categories = Category.roots.ordered.includes(:children).with_attached_image
  end

  def show
    @category = Category.friendly.find(params[:id])
    scope = @category.all_products.published.includes(:category, :brand).with_attached_images
    scope = sort(scope)
    @pagy, @products = pagy(scope)
    @brands = Brand.ordered
  end

  private

  def sort(scope)
    case params[:sort]
    when "price_asc"  then scope.order(price: :asc)
    when "price_desc" then scope.order(price: :desc)
    when "rating"     then scope.top_rated
    when "popular"    then scope.popular
    when "name"       then scope.order_by_translation(:name)
    else scope.recent
    end
  end
end
