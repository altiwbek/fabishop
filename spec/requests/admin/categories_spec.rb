require "rails_helper"

RSpec.describe "Admin::Categories", type: :request do
  let(:category) { create(:category) }

  it "requires authentication" do
    get admin_categories_path
    expect(response).to redirect_to(new_session_path)
  end

  context "when signed in" do
    before { sign_in_as(create(:user)) }

    describe "GET /admin/categories" do
      it "renders the index" do
        category
        get admin_categories_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/categories/new" do
      it "renders the form" do
        get new_admin_category_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/categories/:id/edit" do
      it "renders the form" do
        get edit_admin_category_path(category)
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /admin/categories" do
      it "creates a category with valid params" do
        expect {
          post admin_categories_path, params: { category: { name: "Cameras" } }
        }.to change(Category, :count).by(1)

        expect(response).to redirect_to(admin_categories_path)
      end

      it "re-renders with invalid params" do
        expect {
          post admin_categories_path, params: { category: { name: "" } }
        }.not_to change(Category, :count)

        expect(response).to have_http_status(422)
      end
    end

    describe "PATCH /admin/categories/:id" do
      it "updates the category" do
        patch admin_category_path(category), params: { category: { name: "Renamed" } }

        expect(response).to redirect_to(admin_categories_path)
        expect(category.reload.name).to eq("Renamed")
      end
    end

    describe "DELETE /admin/categories/:id" do
      it "deletes a category without products" do
        category
        expect {
          delete admin_category_path(category)
        }.to change(Category, :count).by(-1)

        expect(response).to redirect_to(admin_categories_path)
      end

      it "refuses to delete a category that still has products" do
        create(:product, category: category)

        expect {
          delete admin_category_path(category)
        }.not_to change(Category, :count)

        expect(response).to redirect_to(admin_categories_path)
        follow_redirect!
        expect(response.body).to match(/Cannot delete record|dependent/i)
      end
    end
  end
end
