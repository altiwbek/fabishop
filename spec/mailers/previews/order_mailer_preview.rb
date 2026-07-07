# Preview order emails at http://localhost:3000/rails/mailers/order_mailer/confirmation
class OrderMailerPreview < ActionMailer::Preview
  def confirmation
    order = Order.recent.first || Order.first
    OrderMailer.with(order: order).confirmation
  end
end
