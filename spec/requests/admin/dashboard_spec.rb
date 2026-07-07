require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  describe "GET /admin" do
    it "redirects to sign in when unauthenticated" do
      get admin_root_path
      expect(response).to redirect_to(new_session_path)
    end

    context "when signed in" do
      before { sign_in_as(create(:user)) }

      it "renders the dashboard" do
        create(:product)
        create(:order)

        get admin_root_path

        expect(response).to have_http_status(:success)
      end
    end
  end
end
