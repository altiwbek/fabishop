class CollectionsController < StorefrontController
  def index
    @collections = Collection.active.ordered.with_attached_cover
  end

  def show
    @collection = Collection.active.friendly.find(params[:id])
    scope = @collection.products.published.includes(:category, :brand).with_attached_images
    @pagy, @products = pagy(scope)
  end
end
