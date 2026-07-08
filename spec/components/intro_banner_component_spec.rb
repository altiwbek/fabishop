# frozen_string_literal: true

require "rails_helper"

RSpec.describe IntroBannerComponent, type: :component do
  let(:collection) { create(:collection, name: "Summer Picks", subtitle: "Handpicked") }

  it "renders the collection name, subtitle and shop link" do
    render_inline(described_class.new(collection: collection))

    expect(page).to have_css("h3.banner-title", text: "Summer Picks")
    expect(page).to have_css("h4.banner-subtitle", text: "Handpicked")
    expect(page).to have_link(href: "/collections/#{collection.to_param}")
  end

  it "falls back to \"Collection\" when the subtitle is blank" do
    collection.update!(subtitle: nil)

    render_inline(described_class.new(collection: collection))

    expect(page).to have_css("h4.banner-subtitle", text: "Collection")
  end

  context "with an attached cover" do
    before { collection.cover.attach(fixture_file_upload("test_image.png", "image/png")) }

    it "renders the cover image with the shared aspect-ratio style" do
      render_inline(described_class.new(collection: collection))

      img = page.find("img")
      expect(img[:src]).to include("/rails/active_storage/")
      expect(img[:style]).to eq(described_class::IMAGE_STYLE)
    end
  end

  context "without a cover" do
    it "falls back to a demo banner image based on the 0-based collection counter" do
      render_inline(described_class.new(collection: collection, collection_counter: 1))

      expect(page).to have_css("img[src='/molla/assets/images/demos/demo-3/banners/banner-2.jpg']")
    end

    it "cycles the demo image number back to the first past the third banner" do
      render_inline(described_class.new(collection: collection, collection_counter: 3))

      expect(page).to have_css("img[src='/molla/assets/images/demos/demo-3/banners/banner-1.jpg']")
    end
  end

  it "renders one banner per collection when used with a collection" do
    collections = create_list(:collection, 3)

    render_inline(described_class.with_collection(collections))

    expect(page).to have_css("div.banner", count: 3)
  end
end
