require "rails_helper"

RSpec.describe "Admin::Posts", type: :request do
  let(:post_record) { create(:post) }

  it "requires authentication" do
    get admin_posts_path
    expect(response).to redirect_to(new_session_path)
  end

  context "when signed in" do
    before { sign_in_as(create(:user)) }

    describe "GET /admin/posts" do
      it "renders the index" do
        post_record
        get admin_posts_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/posts/new" do
      it "renders the form" do
        get new_admin_post_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /admin/posts/:id/edit" do
      it "renders the form" do
        get edit_admin_post_path(post_record)
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /admin/posts" do
      it "creates a post and assigns the current user as author" do
        expect {
          post admin_posts_path, params: { post: { title: "Launch Day", body: "Hello world" } }
        }.to change(Post, :count).by(1)

        expect(response).to redirect_to(admin_posts_path)
        expect(Post.last.author).to be_present
      end

      it "re-renders with invalid params" do
        expect {
          post admin_posts_path, params: { post: { title: "" } }
        }.not_to change(Post, :count)

        expect(response).to have_http_status(422)
      end
    end

    describe "PATCH /admin/posts/:id" do
      it "updates the post" do
        patch admin_post_path(post_record), params: { post: { title: "Renamed" } }

        expect(response).to redirect_to(admin_posts_path)
        expect(post_record.reload.title).to eq("Renamed")
      end
    end

    describe "DELETE /admin/posts/:id" do
      it "deletes the post" do
        post_record
        expect {
          delete admin_post_path(post_record)
        }.to change(Post, :count).by(-1)

        expect(response).to redirect_to(admin_posts_path)
      end
    end
  end
end
