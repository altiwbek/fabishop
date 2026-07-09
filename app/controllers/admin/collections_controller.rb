class Admin::CollectionsController < Admin::BaseController
  before_action :set_collection, only: %i[ show edit update destroy ]

  def index
    @page_title = t("admin.nav.collections")
    @collections = Collection.ordered
  end

  def show
    @page_title = @collection.name
    @in_collection = @collection.products.order("collection_products.position").to_a
    @available = Product.where.not(id: @in_collection.map(&:id)).order_by_translation(:name)
  end

  def new
    @page_title = t("admin.titles.new_collection")
    @collection = Collection.new(active: true)
  end

  def edit
    @page_title = t("admin.titles.edit_collection")
  end

  def create
    @collection = Collection.new(collection_params)
    if @collection.save
      redirect_to admin_collection_path(@collection), notice: t("admin.flash.collection.created")
    else
      @page_title = t("admin.titles.new_collection")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @collection.update(collection_params)
      redirect_to admin_collection_path(@collection), notice: t("admin.flash.collection.updated")
    else
      @page_title = t("admin.titles.edit_collection")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy
    redirect_to admin_collections_path, notice: t("admin.flash.collection.deleted"), status: :see_other
  end

  private

  def set_collection
    @collection = Collection.friendly.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(*translated_keys(:name, :subtitle, :description), :position, :featured, :active, :cover)
  end
end
