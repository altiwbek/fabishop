class Admin::SlidesController < Admin::BaseController
  before_action :set_slide, only: %i[ edit update destroy ]

  def index
    @page_title = t("admin.nav.sliders")
    @slides = Slide.ordered
  end

  def new
    @page_title = t("admin.titles.new_slide")
    @slide = Slide.new(active: true, button_label: "Shop Now")
  end

  def edit
    @page_title = t("admin.titles.edit_slide")
  end

  def create
    @slide = Slide.new(slide_params)
    if @slide.save
      redirect_to admin_slides_path, notice: t("admin.flash.slide.created")
    else
      @page_title = t("admin.titles.new_slide")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @slide.update(slide_params)
      redirect_to admin_slides_path, notice: t("admin.flash.slide.updated")
    else
      @page_title = t("admin.titles.edit_slide")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @slide.destroy
    redirect_to admin_slides_path, notice: t("admin.flash.slide.deleted"), status: :see_other
  end

  private

  def set_slide
    @slide = Slide.find(params[:id])
  end

  def slide_params
    params.require(:slide).permit(*translated_keys(:title, :subtitle, :price_label, :button_label),
                                  :price, :button_url, :position, :active, :image)
  end
end
