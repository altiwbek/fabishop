class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: %i[ show edit update destroy toggle_published ]

  def index
    @page_title = "Products"
    scope = Product.includes(:category, :brand).order(created_at: :desc)
    scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?
    scope = scope.search(params[:q]) if params[:q].present?
    case params[:status]
    when "published" then scope = scope.published
    when "draft"     then scope = scope.where(published: false)
    when "low_stock" then scope = scope.low_stock
    end
    @pagy, @products = pagy(scope, limit: 20)
    @categories = Category.ordered
  end

  def show
    @page_title = @product.name
  end

  def new
    @page_title = "New Product"
    @product = Product.new(published: true, stock: 10)
  end

  def edit
    @page_title = "Edit · #{@product.name}"
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      attach_new_images
      redirect_to admin_product_path(@product), notice: "Product created."
    else
      @page_title = "New Product"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      attach_new_images
      redirect_to admin_product_path(@product), notice: "Product updated."
    else
      @page_title = "Edit · #{@product.name}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: "Product deleted.", status: :see_other
  end

  def toggle_published
    @product.update(published: !@product.published?)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: admin_products_path }
    end
  end

  # Bulk action from the index checkboxes.
  def bulk
    ids = Array(params[:product_ids]).reject(&:blank?)
    products = Product.where(id: ids)
    case params[:bulk_action]
    when "publish"   then products.update_all(published: true, published_at: Time.current)
    when "unpublish" then products.update_all(published: false)
    when "feature"   then products.update_all(featured: true)
    when "delete"    then products.destroy_all
    end
    redirect_to admin_products_path, notice: "#{ids.size} product(s) updated."
  end

  private

  def set_product
    @product = Product.friendly.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :subtitle, :sku, :price, :compare_at_price, :stock,
      :category_id, :brand_id, :published, :featured, :new_arrival, :on_sale,
      :description, collection_ids: []
    )
  end

  # Appends newly uploaded images without purging existing ones.
  def attach_new_images
    files = Array(params.dig(:product, :images)).reject(&:blank?)
    @product.images.attach(files) if files.any?
  end
end
