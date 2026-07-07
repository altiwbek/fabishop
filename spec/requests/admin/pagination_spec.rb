require "rails_helper"

RSpec.describe "Admin pagination", type: :request do
  before { sign_in_as(create(:user)) }

  it "renders Tailwind-styled pagination (not Bootstrap) on multi-page admin index" do
    category = create(:category)
    25.times { create(:product, category: category) }

    get admin_products_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include('aria-label="Pagination"')
    expect(response.body).to include("bg-indigo-600")          # active-page styling
    expect(response.body).not_to include('class="pagination"') # no unstyled Bootstrap markup
  end
end
