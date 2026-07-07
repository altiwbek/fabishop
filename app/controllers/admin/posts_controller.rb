class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: %i[ edit update destroy ]

  def index
    @page_title = "Blog Posts"
    @pagy, @posts = pagy(Post.includes(:author).order(created_at: :desc), limit: 20)
  end

  def new
    @page_title = "New Post"
    @post = Post.new(author: current_user)
  end

  def edit
    @page_title = "Edit Post"
  end

  def create
    @post = Post.new(post_params)
    @post.author ||= current_user
    if @post.save
      redirect_to admin_posts_path, notice: "Post saved."
    else
      @page_title = "New Post"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to admin_posts_path, notice: "Post updated."
    else
      @page_title = "Edit Post"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: "Post deleted.", status: :see_other
  end

  private

  def set_post
    @post = Post.friendly.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :subtitle, :excerpt, :body, :published, :author_id, :cover)
  end
end
