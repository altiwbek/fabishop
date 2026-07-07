require "rails_helper"

RSpec.describe "Admin::Products", type: :request do
  let(:category) { create(:category) }
  let(:product) { create(:product, category: category) }

  it "requires authentication" do
    get admin_products_path
    expect(response).to redirect_to(new_session_path)
  end

  context "when signed in" do
    before { sign_in_as(create(:user)) }

    describe "GET /admin/products" do
      it "renders the index" do
        product
        get admin_products_path
        expect(response).to have_http_status(:success)
      end

      it "renders with filters applied" do
        product
        get admin_products_path, params: { q: product.name, status: "published", category_id: category.id }
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/products/:id" do
      it "renders the show page" do
        get admin_product_path(product)
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/products/new" do
      it "renders the form" do
        get new_admin_product_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/products/:id/edit" do
      it "renders the form" do
        get edit_admin_product_path(product)
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /admin/products" do
      it "creates a product with valid params" do
        expect {
          post admin_products_path, params: {
            product: { name: "Wireless Mouse", price: "29.90", stock: "5", category_id: category.id }
          }
        }.to change(Product, :count).by(1)

        expect(response).to redirect_to(admin_product_path(Product.last))
      end

      it "re-renders with invalid params" do
        expect {
          post admin_products_path, params: { product: { name: "", price: "-1", category_id: category.id } }
        }.not_to change(Product, :count)

        expect(response).to have_http_status(422)
      end
    end

    describe "PATCH /admin/products/:id" do
      it "updates the product" do
        patch admin_product_path(product), params: { product: { name: "Renamed" } }

        expect(response).to redirect_to(admin_product_path(product.reload))
        expect(product.reload.name).to eq("Renamed")
      end
    end

    describe "DELETE /admin/products/:id" do
      it "deletes the product" do
        product
        expect {
          delete admin_product_path(product)
        }.to change(Product, :count).by(-1)

        expect(response).to redirect_to(admin_products_path)
      end
    end

    describe "PATCH /admin/products/:id/toggle_published" do
      it "flips the published flag" do
        product.update!(published: true)

        patch toggle_published_admin_product_path(product)

        expect(product.reload.published).to be(false)
      end
    end

    describe "PATCH /admin/products/bulk" do
      it "applies a bulk action to selected products" do
        p1 = create(:product, category: category, published: false)
        p2 = create(:product, category: category, published: false)

        patch bulk_admin_products_path, params: { bulk_action: "publish", product_ids: [ p1.id, p2.id ] }

        expect(response).to redirect_to(admin_products_path)
        expect(p1.reload.published).to be(true)
        expect(p2.reload.published).to be(true)
      end
    end
  end
end
