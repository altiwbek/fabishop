# ---------------------------------------------------------------------------
# electronics store seed data. Idempotent-ish: clears catalog tables and rebuilds.
# Attaches real images from the Molla template living in public/molla.
# ---------------------------------------------------------------------------

IMG_ROOT = Rails.root.join("public", "molla", "assets", "images")
BLOG_IMAGES = IMG_ROOT.join("blog")

def attach_image(attachable, relative_path, filename = nil)
  path = IMG_ROOT.join(relative_path)
  return unless File.exist?(path)
  attachable.attach(io: File.open(path), filename: filename || File.basename(path), content_type: "image/jpeg")
end

puts "Clearing existing catalog…"
[ OrderItem, Order, Review, CollectionProduct, Product, Collection, Category, Brand, Post, Slide ].each(&:destroy_all)

# ---------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------
puts "Creating users…"
owner = User.find_or_initialize_by(email_address: "admin@electronics.test")
owner.update!(name: "Store Owner", role: :owner, password: "password123", password_confirmation: "password123")

staff = User.find_or_initialize_by(email_address: "staff@electronics.test")
staff.update!(name: "Jane Staff", role: :staff, password: "password123", password_confirmation: "password123")

# ---------------------------------------------------------------------------
# Categories
# ---------------------------------------------------------------------------
puts "Creating categories…"
category_data = [
  { name: "Cameras & Camcorders", featured: true,  description: "Capture every moment in stunning detail." },
  { name: "Smartwatches",         featured: true,  description: "Stay connected on your wrist." },
  { name: "Smartphones",          featured: true,  description: "The latest flagships and everyday phones." },
  { name: "Headphones",           featured: true,  description: "Immersive sound, wired or wireless." },
  { name: "Laptops & Computers",  featured: true,  description: "Power for work, play and everything between." },
  { name: "Speakers",             featured: true,  description: "Fill the room with rich audio." },
  { name: "Gaming",               featured: false, description: "Consoles, controllers and accessories." },
  { name: "TV & Home Theater",    featured: false, description: "Cinematic experiences at home." }
]
categories = category_data.each_with_index.map { |attrs, i| Category.create!(attrs.merge(position: i)) }
cat = categories.index_by(&:name)

# ---------------------------------------------------------------------------
# Brands
# ---------------------------------------------------------------------------
puts "Creating brands…"
brand_names = %w[Apple Samsung Sony GoPro Bose Canon JBL Logitech Anker]
brands = brand_names.each_with_index.map do |name, i|
  b = Brand.create!(name: name, position: i, website: "https://#{name.downcase}.com", description: "#{name} products.")
  attach_image(b.logo, "brands/#{(i % 9) + 1}.png", "#{name.downcase}.png")
  b
end
brand = brands.index_by(&:name)

# ---------------------------------------------------------------------------
# Collections
# ---------------------------------------------------------------------------
puts "Creating collections…"
collection_data = [
  { name: "Featured Products", subtitle: "Handpicked by our team",      featured: true },
  { name: "New Trends",        subtitle: "Fresh arrivals this season",   featured: true },
  { name: "Gift Ideas",        subtitle: "Perfect presents for everyone", featured: true },
  { name: "Clearance Sale",    subtitle: "Limited-time deals",           featured: false },
  { name: "Editor's Picks",    subtitle: "Our favourites right now",     featured: false }
]
collections = collection_data.each_with_index.map { |attrs, i| Collection.create!(attrs.merge(position: i, active: true)) }
coll = collections.index_by(&:name)

# ---------------------------------------------------------------------------
# Products
# ---------------------------------------------------------------------------
puts "Creating products…"
product_specs = [
  { name: "GoPro HERO7 Black Waterproof Action Camera", cat: "Cameras & Camcorders", brand: "GoPro",    price: 349.99, compare: 399.99,  imgs: [ 1 ],        flags: %i[featured on_sale] },
  { name: "Canon EOS Mirrorless Digital Camera",        cat: "Cameras & Camcorders", brand: "Canon",    price: 699.00,                    imgs: [ 3 ],        flags: %i[new_arrival] },
  { name: "Apple Watch Series 3 Sport Band",            cat: "Smartwatches",         brand: "Apple",    price: 214.99,                    imgs: [ 2 ],        flags: %i[featured new_arrival] },
  { name: "Samsung Galaxy Smartwatch 46mm",             cat: "Smartwatches",         brand: "Samsung",  price: 289.00, compare: 329.00,  imgs: [ 4 ],        flags: %i[on_sale] },
  { name: "Apple iPhone Pro 256GB",                     cat: "Smartphones",          brand: "Apple",    price: 999.00,                    imgs: [ 5 ],        flags: %i[featured] },
  { name: "Samsung Galaxy Flagship Phone",              cat: "Smartphones",          brand: "Samsung",  price: 849.00, compare: 949.00,  imgs: [ 6 ],        flags: %i[on_sale new_arrival] },
  { name: "Bose QuietComfort Wireless Headphones",      cat: "Headphones",           brand: "Bose",     price: 279.00,                    imgs: [ 7 ],        flags: %i[featured] },
  { name: "Sony Noise-Cancelling Over-Ear Headphones",  cat: "Headphones",           brand: "Sony",     price: 348.00, compare: 399.00,  imgs: [ 8 ],        flags: %i[on_sale] },
  { name: "JBL Portable Bluetooth Speaker",             cat: "Speakers",             brand: "JBL",      price: 129.95,                    imgs: [ 9 ],        flags: %i[new_arrival] },
  { name: "Bose Home Smart Speaker",                    cat: "Speakers",             brand: "Bose",     price: 199.00,                    imgs: [ 10 ],       flags: %i[featured] },
  { name: "Apple MacBook Ultrabook Laptop",             cat: "Laptops & Computers",  brand: "Apple",    price: 1299.00,                   imgs: [ 11 ],       flags: %i[featured] },
  { name: "Logitech Wireless Gaming Mouse",             cat: "Gaming",               brand: "Logitech", price: 59.99,  compare: 79.99,   imgs: [ 12 ],       flags: %i[on_sale] },
  { name: "Anker Fast Wireless Charging Pad",           cat: "Smartphones",          brand: "Anker",    price: 39.99,                     imgs: [ 13 ],       flags: %i[new_arrival] },
  { name: "Sony 4K Ultra HD Smart TV",                  cat: "TV & Home Theater",    brand: "Sony",     price: 899.00, compare: 1099.00, imgs: [ 14 ],       flags: %i[featured on_sale] },
  { name: "Logitech HD Webcam for Streaming",           cat: "Cameras & Camcorders", brand: "Logitech", price: 89.99,                     imgs: [ 15 ],       flags: [] },
  { name: "Apple Wireless Earbuds Pro",                 cat: "Headphones",           brand: "Apple",    price: 249.00,                    imgs: [ 1 ],        flags: %i[new_arrival featured] },
  { name: "GoPro Fusion 360 Camera",                    cat: "Cameras & Camcorders", brand: "GoPro",    price: 429.00, compare: 499.00,  imgs: [ 3 ],        flags: %i[on_sale] },
  { name: "Samsung Curved Gaming Monitor",              cat: "Gaming",               brand: "Samsung",  price: 349.00,                    imgs: [ 4 ],        flags: [] }
]

sample_desc = <<~HTML
  <p>Experience premium quality and thoughtful design. This product combines cutting-edge
  technology with everyday practicality, so you get performance you can rely on.</p>
  <ul>
    <li>Premium build with durable materials</li>
    <li>Long battery life and fast charging</li>
    <li>Backed by a full manufacturer warranty</li>
  </ul>
  <p>Free shipping on orders over $99 and a 30-day hassle-free return policy.</p>
HTML

products = product_specs.each_with_index.map do |spec, i|
  p = Product.new(
    name: spec[:name],
    subtitle: "#{spec[:brand]} · #{spec[:cat]}",
    category: cat[spec[:cat]],
    brand: brand[spec[:brand]],
    price: spec[:price],
    compare_at_price: spec[:compare],
    stock: [ 0, 3, 8, 15, 25, 40 ].sample,
    sku: "DRD-#{format('%04d', 1000 + i)}",
    published: true,
    featured: spec[:flags].include?(:featured),
    new_arrival: spec[:flags].include?(:new_arrival),
    on_sale: spec[:flags].include?(:on_sale) && spec[:compare].present?
  )
  p.description = sample_desc
  p.save!

  main_indices = Array(spec[:imgs])
  main_indices.each { |idx| attach_image(p.images, "demos/demo-3/products/product-#{idx}.jpg", "product-#{idx}.jpg") }
  extra = ((1..15).to_a - main_indices).sample(2)
  extra.each { |idx| attach_image(p.images, "demos/demo-3/products/product-#{idx}.jpg", "product-#{idx}.jpg") }
  p
end

# ---------------------------------------------------------------------------
# Collection membership
# ---------------------------------------------------------------------------
puts "Assigning products to collections…"
products.select(&:featured?).each    { |p| coll["Featured Products"].products << p }
products.select(&:new_arrival?).each { |p| coll["New Trends"].products << p }
products.select(&:on_sale?).each     { |p| coll["Clearance Sale"].products << p }
products.sample(8).each { |p| coll["Gift Ideas"].products << p unless coll["Gift Ideas"].products.include?(p) }
products.sample(6).each { |p| coll["Editor's Picks"].products << p unless coll["Editor's Picks"].products.include?(p) }

# ---------------------------------------------------------------------------
# Reviews
# ---------------------------------------------------------------------------
puts "Creating reviews…"
review_snippets = [
  [ "Absolutely love it", "Exceeded my expectations. Works flawlessly and looks great.", 5 ],
  [ "Great value",        "Solid build quality for the price. Would recommend.", 4 ],
  [ "Very happy",         "Fast delivery and the product is exactly as described.", 5 ],
  [ "Good but pricey",    "Does the job well, though a little expensive.", 4 ],
  [ "Decent",             "It's fine for everyday use. Nothing spectacular.", 3 ]
]
reviewers = %w[Alex Maria John Aida Nurbek Sophia Daniyar Emma]
products.each do |p|
  rand(0..4).times do
    title, body, rating = review_snippets.sample
    p.reviews.create!(author_name: reviewers.sample, author_email: "reviewer@example.com",
                      rating: rating, title: title, body: body, approved: [ true, true, true, false ].sample)
  end
end

# ---------------------------------------------------------------------------
# Blog posts
# ---------------------------------------------------------------------------
puts "Creating blog posts…"
blog_covers = Dir.glob(BLOG_IMAGES.join("*.jpg")).map { |f| Pathname.new(f) }.first(6)
post_data = [
  { title: "5 Cameras That Will Level Up Your Photography in 2026",
    subtitle: "From vlogging to pro shoots, here are our top picks.",
    excerpt: "Whether you're a beginner or a seasoned pro, the right camera makes all the difference." },
  { title: "The Ultimate Smartwatch Buying Guide",
    subtitle: "Everything you need to know before you buy.",
    excerpt: "Battery life, health tracking, ecosystem — we break down what actually matters." },
  { title: "Wireless vs Wired Headphones: Which Should You Choose?",
    subtitle: "The eternal audiophile debate, settled.",
    excerpt: "Sound quality, convenience and price — a practical comparison." },
  { title: "How to Build the Perfect Home Office Setup",
    subtitle: "Productivity meets comfort.",
    excerpt: "The gadgets and accessories that make working from home a joy." }
]
post_data.each_with_index do |attrs, i|
  post = Post.new(attrs.merge(author: [ owner, staff ].sample, published: true, published_at: (i + 1).days.ago))
  post.body = "<p>#{attrs[:excerpt]}</p>" \
              "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus luctus urna sed urna " \
              "ultricies ac tempor dui sagittis. In condimentum facilisis porta.</p>" \
              "<h3>Our recommendation</h3><p>Head over to the store to explore the full range and find the " \
              "perfect match for your needs.</p>"
  post.save!
  cover = blog_covers[i % blog_covers.size] if blog_covers.any?
  post.cover.attach(io: File.open(cover), filename: cover.basename.to_s, content_type: "image/jpeg") if cover&.exist?
end

# ---------------------------------------------------------------------------
# Homepage slides
# ---------------------------------------------------------------------------
puts "Creating homepage slides…"
slide_data = [
  { title: "Camera Season|Sale.", subtitle: "Daily Deals", price_label: "Save up to", price: "$150.00",
    button_label: "Shop the deals", button_url: "/products?on_sale=1", img: "slide-1.jpg" },
  { title: "Smart Watches|Collection.", subtitle: "New Arrivals", price_label: "Starting at", price: "$99.00",
    button_label: "Discover now", button_url: "/categories/smartwatches", img: "slide-2.jpg" }
]
slide_data.each_with_index do |attrs, i|
  slide = Slide.create!(attrs.except(:img).merge(position: i, active: true))
  attach_image(slide.image, "demos/demo-3/slider/#{attrs[:img]}", attrs[:img])
end

# ---------------------------------------------------------------------------
# Sample orders
# ---------------------------------------------------------------------------
puts "Creating sample orders…"
customers = [
  { first_name: "Aibek",  last_name: "Toktogulov", email: "aibek@example.com",  city: "Bishkek" },
  { first_name: "Sarah",  last_name: "Johnson",    email: "sarah@example.com",  city: "London" },
  { first_name: "Chyngyz", last_name: "Aitmatov",  email: "chyngyz@example.com", city: "Osh" },
  { first_name: "Maria",  last_name: "Garcia",     email: "maria@example.com",  city: "Madrid" },
  { first_name: "Daniel", last_name: "Kim",        email: "daniel@example.com", city: "Seoul" }
]
statuses = %i[pending pending paid shipped delivered]
customers.each_with_index do |c, i|
  order = Order.new(
    email: c[:email], first_name: c[:first_name], last_name: c[:last_name],
    phone: "+996 700 #{format('%06d', rand(1_000_000))}",
    address: "#{rand(1..200)} Chuy Avenue", city: c[:city],
    postal_code: format("%06d", rand(700_000..720_000)), country: "Kyrgyzstan",
    status: statuses[i], created_at: (i + 1).days.ago
  )
  products.sample(rand(1..3)).each do |product|
    qty = rand(1..2)
    order.order_items.build(product: product, product_name: product.name, sku: product.sku,
                            unit_price: product.price, quantity: qty)
  end
  order.recalculate_totals
  order.save!
end

puts "\n✅ Seed complete!"
puts "   Products: #{Product.count} · Categories: #{Category.count} · Collections: #{Collection.count} · Brands: #{Brand.count}"
puts "   Reviews:  #{Review.count} (#{Review.where(approved: true).count} approved) · Posts: #{Post.count} · Orders: #{Order.count} · Slides: #{Slide.count}"
puts "\n   Admin login → /session/new"
puts "   Owner:  admin@electronics.test / password123"
puts "   Staff:  staff@electronics.test / password123"
