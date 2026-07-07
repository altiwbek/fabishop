require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  it "requires authentication" do
    get admin_users_path
    expect(response).to redirect_to(new_session_path)
  end

  context "as a staff member" do
    before { sign_in_as(create(:user)) } # default role: staff

    it "can view the index" do
      get admin_users_path
      expect(response).to have_http_status(:success)
    end

    it "is blocked from the new form" do
      get new_admin_user_path
      expect(response).to redirect_to(admin_root_path)
    end

    it "is blocked from creating users" do
      expect {
        post admin_users_path, params: { user: {
          name: "New", email_address: "new@example.com", role: "staff",
          password: "password", password_confirmation: "password"
        } }
      }.not_to change(User, :count)

      expect(response).to redirect_to(admin_root_path)
    end
  end

  context "as the owner" do
    let(:owner) { create(:user, :owner) }
    before { sign_in_as(owner) }

    describe "GET /admin/users/new" do
      it "renders the form" do
        get new_admin_user_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /admin/users" do
      it "creates a user with valid params" do
        expect {
          post admin_users_path, params: { user: {
            name: "Sam Staff", email_address: "sam@example.com", role: "staff",
            password: "password", password_confirmation: "password"
          } }
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(admin_users_path)
      end

      it "re-renders with invalid params" do
        expect {
          post admin_users_path, params: { user: { name: "", email_address: "" } }
        }.not_to change(User, :count)

        expect(response).to have_http_status(422)
      end
    end

    describe "GET /admin/users/:id/edit" do
      it "renders the form" do
        get edit_admin_user_path(create(:user))
        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH /admin/users/:id" do
      it "updates the user, keeping the password when blank" do
        user = create(:user, name: "Old")

        patch admin_user_path(user), params: { user: { name: "New Name", password: "", password_confirmation: "" } }

        expect(response).to redirect_to(admin_users_path)
        expect(user.reload.name).to eq("New Name")
      end
    end

    describe "DELETE /admin/users/:id" do
      it "deletes another user" do
        other = create(:user)

        expect {
          delete admin_user_path(other)
        }.to change(User, :count).by(-1)

        expect(response).to redirect_to(admin_users_path)
      end

      it "refuses to delete your own account" do
        expect {
          delete admin_user_path(owner)
        }.not_to change(User, :count)

        expect(response).to redirect_to(admin_users_path)
      end
    end
  end
end
