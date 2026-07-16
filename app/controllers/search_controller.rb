class SearchController < StorefrontController
  def index
    @query = params[:q].to_s.strip
    scope = Product.published.search(@query).includes(:category).with_attached_images

    if params[:variant] == "autocomplete"
      @products = scope.limit(6)
      render partial: "search/autocomplete", locals: { products: @products, query: @query }, layout: false
    else
      @pagy, @products = pagy(scope.recent)
    end
  end
end
