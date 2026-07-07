class Admin::UsersController < Admin::BaseController
  before_action :require_owner!, except: :index
  before_action :set_user, only: %i[ edit update destroy ]

  def index
    @page_title = "Staff & Users"
    @users = User.order(:role, :name)
  end

  def new
    @page_title = "New Staff Member"
    @user = User.new
  end

  def edit
    @page_title = "Edit User"
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: "User created."
    else
      @page_title = "New Staff Member"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Allow blank password on update (keep existing).
    attrs = user_params
    attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?
    if @user.update(attrs)
      redirect_to admin_users_path, notice: "User updated."
    else
      @page_title = "Edit User"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "You can't delete your own account."
    else
      @user.destroy
      redirect_to admin_users_path, notice: "User removed.", status: :see_other
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
