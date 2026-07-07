class Products::ReviewsController < StorefrontController
  def create
    @product = Product.published.friendly.find(params[:product_id])
    @review = @product.reviews.new(review_params)
    @review.approved = false # awaits moderation in admin

    respond_to do |format|
      if @review.save
        format.turbo_stream
        format.html { redirect_to product_path(@product), notice: "Thanks! Your review will appear after moderation." }
      else
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { redirect_to product_path(@product), alert: @review.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def review_params
    params.require(:review).permit(:author_name, :author_email, :rating, :title, :body)
  end
end
