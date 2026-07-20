class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  around_action :switch_locale

  helper_method :current_user

  private

  def current_user
    Current.user
  end

  # Pick the active locale, most specific signal first:
  #   1. ?locale= (an explicit choice — persisted below)
  #   2. the signed-in user's saved locale
  #   3. the last choice remembered in the session
  #   4. the browser's Accept-Language header
  #   5. the app default
  # An explicit ?locale= choice is persisted so it survives navigation without
  # keeping the param on every URL, and is saved to the user's account when
  # they're signed in.
  def switch_locale(&action)
    resume_session
    locale = requested_locale ||
             current_user&.locale.presence ||
             session[:locale] ||
             locale_from_header ||
             I18n.default_locale

    # Remember the resolved locale in the session so it sticks after the first
    # visit (e.g. the browser-detected language survives later navigation).
    session[:locale] = locale.to_s

    # An explicit ?locale= choice is also saved to the account for signed-in
    # users so it follows them across devices.
    if requested_locale && current_user && current_user.locale != locale.to_s
      current_user.update_column(:locale, locale.to_s)
    end

    I18n.with_locale(locale, &action)
  end

  def requested_locale
    candidate = params[:locale].to_s.to_sym
    candidate if I18n.available_locales.include?(candidate)
  end

  # Best available locale from the browser's Accept-Language header, honouring
  # its quality weights (e.g. "ru-RU,ru;q=0.9,en;q=0.8"). Returns nil when the
  # header is absent or names no locale we support.
  def locale_from_header
    header = request.env["HTTP_ACCEPT_LANGUAGE"]
    return if header.blank?

    available = I18n.available_locales.map(&:to_s)
    header.split(",").map { |part|
      tag, q = part.split(";q=")
      [ tag.to_s.strip.split("-").first.downcase, (q || "1").to_f ]
    }.sort_by { |_, q| -q }
      .map(&:first)
      .find { |lang| available.include?(lang) }
      &.to_sym
  end

  # Keep the ?locale param on generated URLs only when the current locale is not
  # the default, so shared links preserve the language and default URLs stay clean.
  def default_url_options
    return {} if I18n.locale == I18n.default_locale
    { locale: I18n.locale }
  end
end
