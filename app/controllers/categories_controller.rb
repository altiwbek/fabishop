class CategoriesController < StorefrontController
  def index
    @categories = Category.roots.ordered.includes(:children, image_attachment: :blob)
  end

  def show
    @category = Category.friendly.find(params[:id])
    scope = @category.all_products.published.includes(:category, :brand, images_attachments: :blob)
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
    when "name"       then scope.order(:name)
    else scope.recent
    end
  end
end
