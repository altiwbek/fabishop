class PostsController < StorefrontController
  def index
    @pagy, @posts = pagy(Post.published.recent.includes(:author, cover_attachment: :blob), limit: 9)
  end

  def show
    @post = Post.published.friendly.find(params[:id])
    @post.increment!(:views_count)
    @recent_posts = Post.published.recent.where.not(id: @post.id).limit(4)
  end
end
