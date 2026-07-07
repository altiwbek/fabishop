require "rails_helper"

RSpec.describe "Admin::Reviews", type: :request do
  let(:review) { create(:review, approved: false) }

  it "requires authentication" do
    get admin_reviews_path
    expect(response).to redirect_to(new_session_path)
  end

  context "when signed in" do
    before { sign_in_as(create(:user)) }

    describe "GET /admin/reviews" do
      it "renders the index" do
        review
        get admin_reviews_path
        expect(response).to have_http_status(:success)
      end

      it "renders the pending filter" do
        review
        get admin_reviews_path, params: { filter: "pending" }
        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH /admin/reviews/:id" do
      it "toggles the approved flag" do
        patch admin_review_path(review)

        expect(response).to redirect_to(admin_reviews_path)
        expect(review.reload.approved).to be(true)
      end
    end

    describe "DELETE /admin/reviews/:id" do
      it "deletes the review" do
        review
        expect {
          delete admin_review_path(review)
        }.to change(Review, :count).by(-1)

        expect(response).to redirect_to(admin_reviews_path)
      end
    end
  end
end
