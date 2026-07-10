class Admin::ReviewsController < Admin::BaseController
  before_action :set_review, only: %i[ update destroy ]

  def index
    @page_title = t("admin.nav.reviews")
    scope = Review.includes(:product).order(created_at: :desc)
    scope = scope.where(approved: false) if params[:filter] == "pending"
    scope = scope.where(approved: true) if params[:filter] == "approved"
    @pagy, @reviews = pagy(scope, limit: 20)
    @pending_count = Review.where(approved: false).count
  end

  def update
    @review.update(approved: !@review.approved?)
    redirect_back fallback_location: admin_reviews_path,
                  notice: (@review.approved? ? t("admin.flash.review.approved") : t("admin.flash.review.hidden"))
  end

  def destroy
    @review.destroy
    redirect_to admin_reviews_path, notice: t("admin.flash.review.deleted"), status: :see_other
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end
end
