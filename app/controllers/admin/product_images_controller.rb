class Admin::ProductImagesController < Admin::BaseController
  before_action :set_product

  def create
    files = Array(params.dig(:product, :images)).reject(&:blank?)
    @product.images.attach(files) if files.any?
    redirect_to edit_admin_product_path(@product), notice: "Images added."
  end

  def destroy
    image = @product.images.find(params[:id])
    image.purge_later
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("product_image_#{params[:id]}") }
      format.html { redirect_to edit_admin_product_path(@product), notice: "Image removed." }
    end
  end

  private

  def set_product
    @product = Product.friendly.find(params[:product_id])
  end
end
