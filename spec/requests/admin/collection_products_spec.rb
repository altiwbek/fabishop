require "rails_helper"

RSpec.describe "Admin::CollectionProducts", type: :request do
  let(:collection) { create(:collection) }
  let(:product) { create(:product) }

  it "requires authentication" do
    post admin_collection_collection_products_path(collection), params: { product_id: product.id }
    expect(response).to redirect_to(new_session_path)
  end

  context "when signed in" do
    before { sign_in_as(create(:user)) }

    describe "POST /admin/collections/:collection_id/items" do
      it "adds a product to the collection" do
        expect {
          post admin_collection_collection_products_path(collection), params: { product_id: product.id }
        }.to change { collection.products.count }.by(1)

        expect(response).to redirect_to(admin_collection_path(collection))
      end

      it "does not add the same product twice" do
        create(:collection_product, collection: collection, product: product)

        expect {
          post admin_collection_collection_products_path(collection), params: { product_id: product.id }
        }.not_to change { collection.products.count }
      end
    end

    describe "DELETE /admin/collections/:collection_id/items/:id" do
      it "removes the product from the collection" do
        create(:collection_product, collection: collection, product: product)

        expect {
          delete admin_collection_collection_product_path(collection, product.id)
        }.to change { collection.products.count }.by(-1)

        expect(response).to redirect_to(admin_collection_path(collection))
      end
    end
  end
end
