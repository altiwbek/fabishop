class Admin::CollectionProductsController < Admin::BaseController
  before_action :set_collection

  def create
    product = Product.find(params[:product_id])
    @collection.collection_products.find_or_create_by(product: product) do |cp|
      cp.position = (@collection.collection_products.maximum(:position) || 0) + 1
    end
    redirect_to admin_collection_path(@collection), notice: t("admin.flash.collection_product.added", name: product.name)
  end

  def destroy
    @collection.collection_products.where(product_id: params[:id]).destroy_all
    redirect_to admin_collection_path(@collection), notice: t("admin.flash.collection_product.removed"), status: :see_other
  end

  private

  def set_collection
    @collection = Collection.friendly.find(params[:collection_id])
  end
end
