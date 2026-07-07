require "rails_helper"

RSpec.describe "Admin::Orders", type: :request do
  let(:order) { create(:order) }

  it "requires authentication" do
    get admin_orders_path
    expect(response).to redirect_to(new_session_path)
  end

  context "when signed in" do
    before { sign_in_as(create(:user)) }

    describe "GET /admin/orders" do
      it "renders the index" do
        order
        get admin_orders_path
        expect(response).to have_http_status(:success)
      end

      it "renders filtered by status" do
        order
        get admin_orders_path, params: { status: "pending" }
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/orders/:id" do
      it "renders the show page" do
        create(:order_item, order: order)

        get admin_order_path(order)

        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH /admin/orders/:id" do
      it "updates the order status" do
        patch admin_order_path(order), params: { order: { status: "paid" } }

        expect(response).to redirect_to(admin_order_path(order))
        expect(order.reload.status).to eq("paid")
      end
    end
  end
end
