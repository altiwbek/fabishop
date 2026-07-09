class Admin::BrandsController < Admin::BaseController
  before_action :set_brand, only: %i[ edit update destroy ]

  def index
    @page_title = t("admin.nav.brands")
    @brands = Brand.ordered
  end

  def new
    @page_title = t("admin.titles.new_brand")
    @brand = Brand.new
  end

  def edit
    @page_title = t("admin.titles.edit_brand")
  end

  def create
    @brand = Brand.new(brand_params)
    if @brand.save
      redirect_to admin_brands_path, notice: t("admin.flash.brand.created")
    else
      @page_title = t("admin.titles.new_brand")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @brand.update(brand_params)
      redirect_to admin_brands_path, notice: t("admin.flash.brand.updated")
    else
      @page_title = t("admin.titles.edit_brand")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @brand.destroy
    redirect_to admin_brands_path, notice: t("admin.flash.brand.deleted"), status: :see_other
  end

  private

  def set_brand
    @brand = Brand.friendly.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(*translated_keys(:name, :description), :website, :position, :logo)
  end
end
