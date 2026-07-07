require "rails_helper"

RSpec.describe "Admin::ProductImages", type: :request do
  let(:product) { create(:product) }
  let(:upload) { fixture_file_upload("test_image.png", "image/png") }

  it "requires authentication" do
    post admin_product_product_images_path(product), params: { product: { images: [ upload ] } }
    expect(response).to redirect_to(new_session_path)
  end

  context "when signed in" do
    before { sign_in_as(create(:user)) }

    describe "POST /admin/products/:product_id/images" do
      it "attaches uploaded images" do
        expect {
          post admin_product_product_images_path(product), params: { product: { images: [ upload ] } }
        }.to change { product.images.count }.by(1)

        expect(response).to redirect_to(edit_admin_product_path(product))
      end
    end

    describe "DELETE /admin/products/:product_id/images/:id" do
      it "purges the image" do
        product.images.attach(upload)
        attachment = product.images.first

        delete admin_product_product_image_path(product, attachment.id)

        expect(response).to redirect_to(edit_admin_product_path(product))
        expect(product.reload.images.count).to eq(0)
      end
    end
  end
end
