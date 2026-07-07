class Admin::SlidesController < Admin::BaseController
  before_action :set_slide, only: %i[ edit update destroy ]

  def index
    @page_title = "Homepage Sliders"
    @slides = Slide.ordered
  end

  def new
    @page_title = "New Slide"
    @slide = Slide.new(active: true, button_label: "Shop Now")
  end

  def edit
    @page_title = "Edit Slide"
  end

  def create
    @slide = Slide.new(slide_params)
    if @slide.save
      redirect_to admin_slides_path, notice: "Slide created."
    else
      @page_title = "New Slide"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @slide.update(slide_params)
      redirect_to admin_slides_path, notice: "Slide updated."
    else
      @page_title = "Edit Slide"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @slide.destroy
    redirect_to admin_slides_path, notice: "Slide deleted.", status: :see_other
  end

  private

  def set_slide
    @slide = Slide.find(params[:id])
  end

  def slide_params
    params.require(:slide).permit(:title, :subtitle, :price_label, :price,
                                  :button_label, :button_url, :position, :active, :image)
  end
end
