class CheckoutController < StorefrontController
  before_action :ensure_cart_present

  def new
    @order = Order.new(country: "Kyrgyzstan")
  end

  def create
    @order = Order.new(order_params)
    @order.build_from_cart(current_cart)

    begin
      Order.transaction do
        @order.save!
        deduct_stock(@order)
      end
      OrderMailer.with(order: @order).confirmation.deliver_later
      current_cart.clear
      redirect_to order_path(@order), notice: "Thank you! Your order #{@order.number} has been placed. A confirmation has been emailed to you."
    rescue ActiveRecord::RecordInvalid
      render :new, status: :unprocessable_entity
    end
  end

  private

  def ensure_cart_present
    redirect_to cart_path, alert: "Your cart is empty." if current_cart.empty?
  end

  def deduct_stock(order)
    order.order_items.each do |item|
      next unless item.product
      new_stock = [ item.product.stock - item.quantity, 0 ].max
      item.product.update_column(:stock, new_stock)
    end
  end

  def order_params
    params.require(:order).permit(:email, :first_name, :last_name, :phone,
                                  :address, :city, :postal_code, :country, :notes)
  end
end
