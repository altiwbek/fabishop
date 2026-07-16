module PostsHelper
  POST_PLACEHOLDER = "/molla/assets/images/blog/post-1.jpg".freeze

  def post_cover_url(post)
    post.cover.attached? ? url_for(post.cover.variant(:thumb)) : POST_PLACEHOLDER
  end

  def post_excerpt(post, length: 140)
    text = post.excerpt.presence || post.body.to_plain_text
    truncate(text.to_s, length: length, separator: " ")
  end
end
