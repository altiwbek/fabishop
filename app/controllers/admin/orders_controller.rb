class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: %i[ show update ]

  def index
    @page_title = t("admin.nav.orders")
    scope = Order.recent
    scope = scope.where(status: params[:status]) if params[:status].present? && Order.statuses.key?(params[:status])
    @pagy, @orders = pagy(scope, limit: 20)
    @status_counts = Order.group(:status).count
  end

  def show
    @page_title = t("admin.titles.order", number: @order.number)
  end

  def update
    if @order.update(status: params.dig(:order, :status))
      redirect_to admin_order_path(@order), notice: t("admin.flash.order.status", status: t("admin.orders.statuses.#{@order.status}"))
    else
      redirect_to admin_order_path(@order), alert: t("admin.flash.order.error")
    end
  end

  private

  def set_order
    @order = Order.includes(order_items: :product).find_by!(token: params[:id])
  end
end
