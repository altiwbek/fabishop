module ApplicationHelper
  include Pagy::Frontend

  def page_title(text)
    content_for(:title) { "#{text} — MegaShop" }
  end

  def slide_image_url(slide, fallback: "/molla/assets/images/demos/demo-3/slider/slide-1.jpg")
    slide.image.attached? ? url_for(slide.image) : fallback
  end

  # Tailwind-styled pagination for the admin area, which does not load Bootstrap
  # CSS (so pagy_bootstrap_nav renders unstyled there). Mirrors Pagy's series
  # API: Integer -> link, String -> current page, :gap -> ellipsis.
  def pagy_tailwind_nav(pagy, **vars)
    anchor = pagy_anchor(pagy, **vars)

    base     = "inline-flex items-center justify-center min-w-9 h-9 px-3 text-sm rounded-md border transition-colors"
    link     = "#{base} border-gray-300 text-gray-700 bg-white hover:bg-gray-50"
    current  = "#{base} border-indigo-600 bg-indigo-600 text-white font-semibold"
    disabled = "#{base} border-gray-200 text-gray-300 bg-white cursor-not-allowed"

    html = +%(<nav class="flex items-center gap-1" aria-label="Pagination">)

    html << if pagy.prev
      anchor.call(pagy.prev, pagy_t("pagy.prev"), classes: link, aria_label: pagy_t("pagy.aria_label.prev"))
    else
      %(<span class="#{disabled}">#{pagy_t("pagy.prev")}</span>)
    end

    pagy.series(**vars).each do |item|
      html << case item
              when Integer then anchor.call(item, classes: link)
              when String  then %(<span class="#{current}" aria-current="page">#{pagy.label_for(item)}</span>)
              when :gap    then %(<span class="#{disabled}">#{pagy_t("pagy.gap")}</span>)
      end
    end

    html << if pagy.next
      anchor.call(pagy.next, pagy_t("pagy.next"), classes: link, aria_label: pagy_t("pagy.aria_label.next"))
    else
      %(<span class="#{disabled}">#{pagy_t("pagy.next")}</span>)
    end

    html << %(</nav>)
    html.html_safe
  end
end
