class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: %i[ edit update destroy ]

  def index
    @page_title = t("admin.nav.posts")
    @pagy, @posts = pagy(Post.includes(:author).order(created_at: :desc), limit: 20)
  end

  def new
    @page_title = t("admin.titles.new_post")
    @post = Post.new(author: current_user)
  end

  def edit
    @page_title = t("admin.titles.edit_post")
  end

  def create
    @post = Post.new(post_params)
    @post.author ||= current_user
    if @post.save
      redirect_to admin_posts_path, notice: t("admin.flash.post.saved")
    else
      @page_title = t("admin.titles.new_post")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to admin_posts_path, notice: t("admin.flash.post.updated")
    else
      @page_title = t("admin.titles.edit_post")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: t("admin.flash.post.deleted"), status: :see_other
  end

  private

  def set_post
    @post = Post.friendly.find(params[:id])
  end

  def post_params
    params.require(:post).permit(*translated_keys(:title, :subtitle, :excerpt), :body, :published, :author_id, :cover)
  end
end
