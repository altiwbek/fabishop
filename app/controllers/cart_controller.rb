class CartController < StorefrontController
  def show
    @cart = current_cart
  end

  def add
    product = Product.published.find(params[:product_id])
    current_cart.add(product.id, params[:quantity].presence || 1)
    @toast = "#{product.name} added to your cart"
    respond_with_stream
  end

  def update
    current_cart.set(params[:product_id], params[:quantity])
    respond_with_stream
  end

  def remove
    current_cart.remove(params[:product_id])
    respond_with_stream
  end

  def clear
    current_cart.clear
    respond_with_stream(redirect: cart_path)
  end

  private

  def respond_with_stream(redirect: nil)
    respond_to do |format|
      format.turbo_stream { render :stream }
      format.html { redirect_to(redirect || cart_path) }
    end
  end
end
