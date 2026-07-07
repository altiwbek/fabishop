class Admin::BrandsController < Admin::BaseController
  before_action :set_brand, only: %i[ edit update destroy ]

  def index
    @page_title = "Brands"
    @brands = Brand.ordered
  end

  def new
    @page_title = "New Brand"
    @brand = Brand.new
  end

  def edit
    @page_title = "Edit Brand"
  end

  def create
    @brand = Brand.new(brand_params)
    if @brand.save
      redirect_to admin_brands_path, notice: "Brand created."
    else
      @page_title = "New Brand"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @brand.update(brand_params)
      redirect_to admin_brands_path, notice: "Brand updated."
    else
      @page_title = "Edit Brand"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @brand.destroy
    redirect_to admin_brands_path, notice: "Brand deleted.", status: :see_other
  end

  private

  def set_brand
    @brand = Brand.friendly.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(:name, :description, :website, :position, :logo)
  end
end
