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

  # Pick the active locale from ?locale= (validated), else the last choice
  # remembered in the session, else the app default. The choice is persisted so
  # it survives navigation without keeping the param on every URL.
  def switch_locale(&action)
    locale = requested_locale || session[:locale] || I18n.default_locale
    session[:locale] = locale
    I18n.with_locale(locale, &action)
  end

  def requested_locale
    candidate = params[:locale].to_s.to_sym
    candidate if I18n.available_locales.include?(candidate)
  end

  # Keep the ?locale param on generated URLs only when the current locale is not
  # the default, so shared links preserve the language and default URLs stay clean.
  def default_url_options
    return {} if I18n.locale == I18n.default_locale
    { locale: I18n.locale }
  end
end
