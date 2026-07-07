require "rails_helper"

RSpec.describe "Admin::Collections", type: :request do
  let(:collection) { create(:collection) }

  it "requires authentication" do
    get admin_collections_path
    expect(response).to redirect_to(new_session_path)
  end

  context "when signed in" do
    before { sign_in_as(create(:user)) }

    describe "GET /admin/collections" do
      it "renders the index" do
        collection
        get admin_collections_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/collections/:id" do
      it "renders the show page" do
        create(:product)
        get admin_collection_path(collection)
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/collections/new" do
      it "renders the form" do
        get new_admin_collection_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/collections/:id/edit" do
      it "renders the form" do
        get edit_admin_collection_path(collection)
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /admin/collections" do
      it "creates a collection with valid params" do
        expect {
          post admin_collections_path, params: { collection: { name: "Summer Sale" } }
        }.to change(Collection, :count).by(1)

        expect(response).to redirect_to(admin_collection_path(Collection.last))
      end

      it "re-renders with invalid params" do
        expect {
          post admin_collections_path, params: { collection: { name: "" } }
        }.not_to change(Collection, :count)

        expect(response).to have_http_status(422)
      end
    end

    describe "PATCH /admin/collections/:id" do
      it "updates the collection" do
        patch admin_collection_path(collection), params: { collection: { name: "Renamed" } }

        expect(response).to redirect_to(admin_collection_path(collection.reload))
        expect(collection.reload.name).to eq("Renamed")
      end
    end

    describe "DELETE /admin/collections/:id" do
      it "deletes the collection" do
        collection
        expect {
          delete admin_collection_path(collection)
        }.to change(Collection, :count).by(-1)

        expect(response).to redirect_to(admin_collections_path)
      end
    end
  end
end
