class Admin::BaseController < ApplicationController
  # Authentication is required by default (inherited from ApplicationController).
  layout "admin"

  before_action :set_page_title

  private

  # Owner-only areas can call `require_owner!` in a before_action.
  def require_owner!
    return if current_user&.owner?
    redirect_to admin_root_path, alert: "Only the store owner can do that."
  end

  def set_page_title
    @page_title = "Admin"
  end
end
