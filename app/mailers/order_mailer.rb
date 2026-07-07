class OrderMailer < ApplicationMailer
  def confirmation
    @order = params[:order]
    mail(to: @order.email, subject: "Your MegaShop order #{@order.number} is confirmed")
  end
end
