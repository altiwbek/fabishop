module ApplicationHelper
  include Pagy::Frontend

  def page_title(text)
    content_for(:title) { "#{text} — Fabishop" }
  end

  def slide_image_url(slide, fallback: "/molla/assets/images/demos/demo-3/slider/slide-1.jpg")
    slide.image.attached? ? url_for(slide.image.variant(:hero)) : fallback
  end

  # Human-readable native names for the languages we support, keyed by locale.
  LOCALE_NAMES = { en: "English", ru: "Русский", ky: "Кыргызча" }.freeze
  LOCALE_SHORT = { en: "EN", ru: "RU", ky: "KY" }.freeze

  def available_locales
    I18n.available_locales
  end

  def locale_name(locale)
    LOCALE_NAMES[locale.to_sym] || locale.to_s
  end

  def locale_short(locale)
    LOCALE_SHORT[locale.to_sym] || locale.to_s.upcase
  end

  # URL for the current page switched to another locale, preserving the path and
  # existing query params.
  def switch_locale_url(locale)
    url_for(request.query_parameters.merge(locale: locale, only_path: true))
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
