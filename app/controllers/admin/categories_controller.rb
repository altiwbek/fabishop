class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: %i[ edit update destroy ]

  def index
    @page_title = "Categories"
    @categories = Category.includes(:parent).ordered
  end

  def new
    @page_title = "New Category"
    @category = Category.new
  end

  def edit
    @page_title = "Edit Category"
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_categories_path, notice: "Category created."
    else
      @page_title = "New Category"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: "Category updated."
    else
      @page_title = "Edit Category"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      redirect_to admin_categories_path, notice: "Category deleted.", status: :see_other
    else
      redirect_to admin_categories_path, alert: @category.errors.full_messages.to_sentence
    end
  end

  private

  def set_category
    @category = Category.friendly.find(params[:id])
  end

  def category_params
    params.require(:category).permit(*translated_keys(:name, :description), :position, :featured, :parent_id, :image)
  end
end
