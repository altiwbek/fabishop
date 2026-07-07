require "rails_helper"

RSpec.describe "Admin::Brands", type: :request do
  let(:brand) { create(:brand) }

  it "requires authentication" do
    get admin_brands_path
    expect(response).to redirect_to(new_session_path)
  end

  context "when signed in" do
    before { sign_in_as(create(:user)) }

    describe "GET /admin/brands" do
      it "renders the index" do
        brand
        get admin_brands_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/brands/new" do
      it "renders the form" do
        get new_admin_brand_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/brands/:id/edit" do
      it "renders the form" do
        get edit_admin_brand_path(brand)
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /admin/brands" do
      it "creates a brand with valid params" do
        expect {
          post admin_brands_path, params: { brand: { name: "Acme" } }
        }.to change(Brand, :count).by(1)

        expect(response).to redirect_to(admin_brands_path)
      end

      it "re-renders with invalid params" do
        expect {
          post admin_brands_path, params: { brand: { name: "" } }
        }.not_to change(Brand, :count)

        expect(response).to have_http_status(422)
      end
    end

    describe "PATCH /admin/brands/:id" do
      it "updates the brand" do
        patch admin_brand_path(brand), params: { brand: { name: "Renamed" } }

        expect(response).to redirect_to(admin_brands_path)
        expect(brand.reload.name).to eq("Renamed")
      end
    end

    describe "DELETE /admin/brands/:id" do
      it "deletes the brand" do
        brand
        expect {
          delete admin_brand_path(brand)
        }.to change(Brand, :count).by(-1)

        expect(response).to redirect_to(admin_brands_path)
      end
    end
  end
end
