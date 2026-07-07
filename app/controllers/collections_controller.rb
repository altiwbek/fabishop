class CollectionsController < StorefrontController
  def index
    @collections = Collection.active.ordered.includes(cover_attachment: :blob)
  end

  def show
    @collection = Collection.active.friendly.find(params[:id])
    scope = @collection.products.published.includes(:category, :brand, images_attachments: :blob)
    @pagy, @products = pagy(scope)
  end
end
