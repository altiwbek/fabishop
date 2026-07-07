require "rails_helper"

RSpec.describe "Passwords", type: :request do
  let(:user) { create(:user) }

  describe "GET /passwords/new" do
    it "renders" do
      get new_password_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /passwords" do
    it "enqueues reset instructions for a known user" do
      expect {
        post passwords_path, params: { email_address: user.email_address }
      }.to have_enqueued_mail(PasswordsMailer, :reset).with(user)

      expect(response).to redirect_to(new_session_path)

      follow_redirect!
      expect(response.body).to match(/reset instructions sent/)
    end

    it "redirects but sends no mail for an unknown user" do
      expect {
        post passwords_path, params: { email_address: "missing-user@example.com" }
      }.not_to have_enqueued_mail

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET /passwords/:token/edit" do
    it "renders with a valid token" do
      get edit_password_path(user.password_reset_token)
      expect(response).to have_http_status(:success)
    end

    it "redirects with an invalid token" do
      get edit_password_path("invalid token")

      expect(response).to redirect_to(new_password_path)

      follow_redirect!
      expect(response.body).to match(/reset link is invalid/)
    end
  end

  describe "PUT /passwords/:token" do
    it "resets the password with a matching confirmation" do
      expect {
        put password_path(user.password_reset_token),
          params: { password: "new-password", password_confirmation: "new-password" }
      }.to change { user.reload.password_digest }

      expect(response).to redirect_to(new_session_path)

      follow_redirect!
      expect(response.body).to match(/Password has been reset/)
    end

    it "does not reset with non-matching passwords" do
      token = user.password_reset_token

      expect {
        put password_path(token), params: { password: "no", password_confirmation: "match" }
      }.not_to change { user.reload.password_digest }

      expect(response).to redirect_to(edit_password_path(token))

      follow_redirect!
      expect(response.body).to match(/Passwords did not match/)
    end
  end
end
