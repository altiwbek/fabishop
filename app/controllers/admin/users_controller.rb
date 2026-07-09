class Admin::UsersController < Admin::BaseController
  before_action :require_owner!, except: :index
  before_action :set_user, only: %i[ edit update destroy ]

  def index
    @page_title = t("admin.nav.users")
    @users = User.order(:role, :name)
  end

  def new
    @page_title = t("admin.titles.new_staff")
    @user = User.new
  end

  def edit
    @page_title = t("admin.titles.edit_user")
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: t("admin.flash.user.created")
    else
      @page_title = t("admin.titles.new_staff")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Allow blank password on update (keep existing).
    attrs = user_params
    attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?
    if @user.update(attrs)
      redirect_to admin_users_path, notice: t("admin.flash.user.updated")
    else
      @page_title = t("admin.titles.edit_user")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: t("admin.flash.user.self_delete")
    else
      @user.destroy
      redirect_to admin_users_path, notice: t("admin.flash.user.deleted"), status: :see_other
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email_address, :role, :password, :password_confirmation)
  end
end
