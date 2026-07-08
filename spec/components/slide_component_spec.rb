# frozen_string_literal: true

require "rails_helper"

RSpec.describe SlideComponent, type: :component do
  let(:slide) do
    create(:slide, title: "Summer Sale", subtitle: "Limited time").tap do |s|
      s.image.attach(fixture_file_upload("test_image.png", "image/png"))
    end
  end

  it "renders the slide title and subtitle" do
    render_inline(described_class.new(slide: slide))

    expect(page).to have_css("h1.intro-title", text: "Summer Sale")
    expect(page).to have_css("h3.intro-subtitle", text: "Limited time")
    expect(page).to have_css("figure.slide-image img")
  end

  it "renders a placeholder image when no image is attached" do
    slide.image.detach

    render_inline(described_class.new(slide: slide))

    expect(page).to have_css("figure.slide-image img")
  end

  it "renders a title with a manual line break" do
    slide.title = "Big|Deals"

    render_inline(described_class.new(slide: slide))

    expect(page.native.to_html).to include("Big<br>Deals")
  end

  context "with pricing" do
    before { slide.assign_attributes(price: "$99", price_label: "from") }

    it "renders the price and label" do
      render_inline(described_class.new(slide: slide))

      expect(page).to have_css(".intro-price sup", text: "from")
      expect(page).to have_css(".intro-price span", text: "$99")
    end
  end

  context "without a price" do
    it "omits the price block" do
      render_inline(described_class.new(slide: slide))

      expect(page).to have_no_css(".intro-price")
    end
  end

  context "with a button" do
    it "links to the given url" do
      slide.assign_attributes(button_label: "Shop now", button_url: "/collections/summer")

      render_inline(described_class.new(slide: slide))

      expect(page).to have_link("Shop now", href: "/collections/summer")
    end

    it "falls back to the products path when no url is set" do
      slide.assign_attributes(button_label: "Shop now", button_url: nil)

      render_inline(described_class.new(slide: slide))

      expect(page).to have_link("Shop now", href: "/products")
    end
  end

  context "without a button label" do
    it "omits the button" do
      slide.button_label = nil

      render_inline(described_class.new(slide: slide))

      expect(page).to have_no_css("a.btn")
    end
  end
end
