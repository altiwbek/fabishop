class OrderTrackingController < StorefrontController
  def new
  end

  def create
    number = params[:number].to_s.strip
    email  = params[:email].to_s.strip.downcase

    order = Order.where("lower(email) = ?", email).find_by(number: number)
    if order
      redirect_to order_path(order)
    else
      flash.now[:alert] = "We couldn't find an order with that number and email. Please check and try again."
      @number = number
      @email = params[:email]
      render :new, status: :unprocessable_entity
    end
  end
end
