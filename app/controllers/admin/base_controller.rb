class Admin::BaseController < ApplicationController
  # Authentication is required by default (inherited from ApplicationController).
  layout "admin"

  before_action :set_page_title

  private

  # Expand translated attribute names into strong-params keys: the bare attribute
  # (writes the current locale) plus each per-locale accessor, e.g.
  # translated_keys(:name) => [:name, :name_en, :name_ru, :name_ky].
  # This lets admin forms submit a value per language while a plain `name` param
  # still assigns the active locale.
  def translated_keys(*attributes)
    attributes.flat_map do |attr|
      [ attr, *I18n.available_locales.map { |locale| :"#{attr}_#{locale}" } ]
    end
  end

  # Owner-only areas can call `require_owner!` in a before_action.
  def require_owner!
    return if current_user&.owner?
    redirect_to admin_root_path, alert: t("admin.flash.owner_only")
  end

  def set_page_title
    @page_title = "Admin"
  end
end
