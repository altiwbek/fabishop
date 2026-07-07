module ApplicationHelper
  include Pagy::Frontend

  def page_title(text)
    content_for(:title) { "#{text} — electronics" }
  end

  def slide_image_url(slide, fallback: "/molla/assets/images/demos/demo-3/slider/slide-1.jpg")
    slide.image.attached? ? url_for(slide.image) : fallback
  end
end
