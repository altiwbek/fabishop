class OrderMailer < ApplicationMailer
  def confirmation
    @order = params[:order]
    mail(to: @order.email, subject: "Your electronics order #{@order.number} is confirmed")
  end
end
