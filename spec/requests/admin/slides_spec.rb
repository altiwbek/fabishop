require "rails_helper"

RSpec.describe "Admin::Slides", type: :request do
  let(:slide) { create(:slide) }

  it "requires authentication" do
    get admin_slides_path
    expect(response).to redirect_to(new_session_path)
  end

  context "when signed in" do
    before { sign_in_as(create(:user)) }

    describe "GET /admin/slides" do
      it "renders the index" do
        slide
        get admin_slides_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/slides/new" do
      it "renders the form" do
        get new_admin_slide_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/slides/:id/edit" do
      it "renders the form" do
        get edit_admin_slide_path(slide)
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /admin/slides" do
      it "creates a slide with valid params" do
        expect {
          post admin_slides_path, params: { slide: { title: "Big Sale" } }
        }.to change(Slide, :count).by(1)

        expect(response).to redirect_to(admin_slides_path)
      end

      it "re-renders the form with invalid params" do
        expect {
          post admin_slides_path, params: { slide: { title: "" } }
        }.not_to change(Slide, :count)

        expect(response).to have_http_status(422)
        # Assert the form actually re-rendered. A template error would raise
        # here (request specs re-raise) and fail loudly, rather than being
        # swallowed.
        expect(response.body).to include("Create slide")
      end
    end

    describe "PATCH /admin/slides/:id" do
      it "updates the slide" do
        patch admin_slide_path(slide), params: { slide: { title: "Updated" } }

        expect(response).to redirect_to(admin_slides_path)
        expect(slide.reload.title).to eq("Updated")
      end
    end

    describe "DELETE /admin/slides/:id" do
      it "deletes the slide" do
        slide
        expect {
          delete admin_slide_path(slide)
        }.to change(Slide, :count).by(-1)

        expect(response).to redirect_to(admin_slides_path)
      end
    end
  end
end
