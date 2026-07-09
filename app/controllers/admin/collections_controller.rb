class Admin::CollectionsController < Admin::BaseController
  before_action :set_collection, only: %i[ show edit update destroy ]

  def index
    @page_title = "Collections"
    @collections = Collection.ordered
  end

  def show
    @page_title = @collection.name
    @in_collection = @collection.products.order("collection_products.position").to_a
    @available = Product.where.not(id: @in_collection.map(&:id)).order_by_translation(:name)
  end

  def new
    @page_title = "New Collection"
    @collection = Collection.new(active: true)
  end

  def edit
    @page_title = "Edit Collection"
  end

  def create
    @collection = Collection.new(collection_params)
    if @collection.save
      redirect_to admin_collection_path(@collection), notice: "Collection created."
    else
      @page_title = "New Collection"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @collection.update(collection_params)
      redirect_to admin_collection_path(@collection), notice: "Collection updated."
    else
      @page_title = "Edit Collection"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy
    redirect_to admin_collections_path, notice: "Collection deleted.", status: :see_other
  end

  private

  def set_collection
    @collection = Collection.friendly.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(*translated_keys(:name, :subtitle, :description), :position, :featured, :active, :cover)
  end
end
