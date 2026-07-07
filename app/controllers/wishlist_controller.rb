class WishlistController < StorefrontController
  def show
    @products = current_wishlist.products.includes(:category, images_attachments: :blob)
  end

  def toggle
    product = Product.published.find(params[:product_id])
    current_wishlist.toggle(product.id)
    @toast = current_wishlist.include?(product.id) ? "Added to wishlist" : "Removed from wishlist"
    respond_with_stream
  end

  def remove
    current_wishlist.remove(params[:product_id])
    respond_with_stream(redirect: wishlist_path)
  end

  private

  def respond_with_stream(redirect: nil)
    respond_to do |format|
      format.turbo_stream { render :stream }
      format.html { redirect_to(redirect || wishlist_path) }
    end
  end
end
