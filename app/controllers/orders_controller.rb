class OrdersController < StorefrontController
  def show
    @order = Order.includes(order_items: :product).find_by!(token: params[:token])
  end
end
