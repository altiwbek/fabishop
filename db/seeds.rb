# ---------------------------------------------------------------------------
# electronics store seed data. Idempotent-ish: clears catalog tables and rebuilds.
# Attaches real images from the Molla template living in public/molla.
#
# Translatable attributes (Mobility :container backend) are seeded in all three
# supported locales: English (en), Russian (ru) and Kyrgyz (ky). Rich-text
# bodies (product descriptions, post bodies) are not Mobility-translated in this
# app, so they stay in English.
# ---------------------------------------------------------------------------

IMG_ROOT = Rails.root.join("public", "molla", "assets", "images")
BLOG_IMAGES = IMG_ROOT.join("blog")

def attach_image(attachable, relative_path, filename = nil)
  path = IMG_ROOT.join(relative_path)
  return unless File.exist?(path)
  attachable.attach(io: File.open(path), filename: filename || File.basename(path), content_type: "image/jpeg")
end

# Sets a translated attribute across every locale. `values` is a hash keyed by
# locale, e.g. tr(product, :name, en: "…", ru: "…", ky: "…").
def tr(record, attr, **values)
  values.each do |locale, value|
    next if value.nil?
    Mobility.with_locale(locale) { record.public_send("#{attr}=", value) }
  end
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
  { featured: true,
    en: "Cameras & Camcorders", ru: "Камеры и видеокамеры", ky: "Камералар жана видеокамералар",
    desc_en: "Capture every moment in stunning detail.",
    desc_ru: "Запечатлейте каждый момент в потрясающих деталях.",
    desc_ky: "Ар бир учурду укмуштуудай тактыкта тартып алыңыз." },
  { featured: true,
    en: "Smartwatches", ru: "Смарт-часы", ky: "Акылдуу сааттар",
    desc_en: "Stay connected on your wrist.",
    desc_ru: "Оставайтесь на связи прямо на запястье.",
    desc_ky: "Билегиңизде байланышта болуңуз." },
  { featured: true,
    en: "Smartphones", ru: "Смартфоны", ky: "Смартфондор",
    desc_en: "The latest flagships and everyday phones.",
    desc_ru: "Новейшие флагманы и телефоны на каждый день.",
    desc_ky: "Эң акыркы флагмандар жана күнүмдүк телефондор." },
  { featured: true,
    en: "Headphones", ru: "Наушники", ky: "Кулакчындар",
    desc_en: "Immersive sound, wired or wireless.",
    desc_ru: "Погружающий звук — проводной или беспроводной.",
    desc_ky: "Зымдуу же зымсыз — таасирдүү добуш." },
  { featured: true,
    en: "Laptops & Computers", ru: "Ноутбуки и компьютеры", ky: "Ноутбуктар жана компьютерлер",
    desc_en: "Power for work, play and everything between.",
    desc_ru: "Мощность для работы, игр и всего между ними.",
    desc_ky: "Иш, оюн жана алардын ортосундагы баары үчүн кубат." },
  { featured: true,
    en: "Speakers", ru: "Колонки", ky: "Динамиктер",
    desc_en: "Fill the room with rich audio.",
    desc_ru: "Наполните комнату насыщенным звуком.",
    desc_ky: "Бөлмөнү бай добуш менен толтуруңуз." },
  { featured: false,
    en: "Gaming", ru: "Игры", ky: "Оюндар",
    desc_en: "Consoles, controllers and accessories.",
    desc_ru: "Консоли, контроллеры и аксессуары.",
    desc_ky: "Консолдор, контроллерлер жана аксессуарлар." },
  { featured: false,
    en: "TV & Home Theater", ru: "ТВ и домашний кинотеатр", ky: "ТВ жана үй кинотеатры",
    desc_en: "Cinematic experiences at home.",
    desc_ru: "Кинематографические впечатления дома.",
    desc_ky: "Үйдө кинематографиялык таасирлер." }
]
categories = category_data.each_with_index.map do |d, i|
  c = Category.new(featured: d[:featured], position: i)
  tr(c, :name, en: d[:en], ru: d[:ru], ky: d[:ky])
  tr(c, :description, en: d[:desc_en], ru: d[:desc_ru], ky: d[:desc_ky])
  c.save!
  c
end
cat = categories.index_by { |c| Mobility.with_locale(:en) { c.name } }
# English category name → its translations, used to build product subtitles.
cat_tr = category_data.index_by { |d| d[:en] }

# ---------------------------------------------------------------------------
# Brands
# ---------------------------------------------------------------------------
puts "Creating brands…"
# Brand names are proper nouns, identical in every locale (ru/ky fall back to
# en), so only the description is translated.
brand_names = %w[Apple Samsung Sony GoPro Bose Canon JBL Logitech Anker]
brands = brand_names.each_with_index.map do |name, i|
  b = Brand.new(name: name, position: i, website: "https://#{name.downcase}.com")
  tr(b, :description, en: "#{name} products.", ru: "Продукция #{name}.", ky: "#{name} өнүмдөрү.")
  b.save!
  attach_image(b.logo, "brands/#{(i % 9) + 1}.png", "#{name.downcase}.png")
  b
end
brand = brands.index_by(&:name)

# ---------------------------------------------------------------------------
# Collections
# ---------------------------------------------------------------------------
puts "Creating collections…"
collection_data = [
  { featured: true,
    en: "Featured Products", ru: "Рекомендуемые товары", ky: "Тандалма товарлар",
    sub_en: "Handpicked by our team", sub_ru: "Отобрано нашей командой", sub_ky: "Биздин команда тарабынан тандалган" },
  { featured: true,
    en: "New Trends", ru: "Новые тренды", ky: "Жаңы тренддер",
    sub_en: "Fresh arrivals this season", sub_ru: "Свежие поступления этого сезона", sub_ky: "Бул мезгилдин жаңы келүүлөрү" },
  { featured: true,
    en: "Gift Ideas", ru: "Идеи подарков", ky: "Белек идеялары",
    sub_en: "Perfect presents for everyone", sub_ru: "Идеальные подарки для каждого", sub_ky: "Ар бир адам үчүн эң сонун белектер" },
  { featured: false,
    en: "Clearance Sale", ru: "Распродажа", ky: "Арзандатуу сатуу",
    sub_en: "Limited-time deals", sub_ru: "Предложения ограниченного времени", sub_ky: "Убакыты чектелген сунуштар" },
  { featured: false,
    en: "Editor's Picks", ru: "Выбор редакции", ky: "Редакциянын тандоосу",
    sub_en: "Our favourites right now", sub_ru: "Наши фавориты прямо сейчас", sub_ky: "Учурдагы биздин сүйүктүүлөрүбүз" }
]
collections = collection_data.each_with_index.map do |d, i|
  c = Collection.new(position: i, active: true, featured: d[:featured])
  tr(c, :name, en: d[:en], ru: d[:ru], ky: d[:ky])
  tr(c, :subtitle, en: d[:sub_en], ru: d[:sub_ru], ky: d[:sub_ky])
  c.save!
  c
end
coll = collections.index_by { |c| Mobility.with_locale(:en) { c.name } }

# ---------------------------------------------------------------------------
# Products
# ---------------------------------------------------------------------------
puts "Creating products…"
product_specs = [
  { name_en: "GoPro HERO7 Black Waterproof Action Camera",
    name_ru: "Экшн-камера GoPro HERO7 Black водонепроницаемая",
    name_ky: "GoPro HERO7 Black суу өткөрбөс экшн-камера",
    cat: "Cameras & Camcorders", brand: "GoPro", price: 349.99, compare: 399.99, imgs: [ 1 ], flags: %i[featured on_sale] },
  { name_en: "Canon EOS Mirrorless Digital Camera",
    name_ru: "Беззеркальная цифровая камера Canon EOS",
    name_ky: "Canon EOS күзгүсүз санариптик камера",
    cat: "Cameras & Camcorders", brand: "Canon", price: 699.00, imgs: [ 3 ], flags: %i[new_arrival] },
  { name_en: "Apple Watch Series 3 Sport Band",
    name_ru: "Apple Watch Series 3 со спортивным ремешком",
    name_ky: "Apple Watch Series 3 спорттук кайыш менен",
    cat: "Smartwatches", brand: "Apple", price: 214.99, imgs: [ 2 ], flags: %i[featured new_arrival] },
  { name_en: "Samsung Galaxy Smartwatch 46mm",
    name_ru: "Смарт-часы Samsung Galaxy 46 мм",
    name_ky: "Samsung Galaxy акылдуу саат 46 мм",
    cat: "Smartwatches", brand: "Samsung", price: 289.00, compare: 329.00, imgs: [ 4 ], flags: %i[on_sale] },
  { name_en: "Apple iPhone Pro 256GB",
    name_ru: "Apple iPhone Pro 256 ГБ",
    name_ky: "Apple iPhone Pro 256 ГБ",
    cat: "Smartphones", brand: "Apple", price: 999.00, imgs: [ 5 ], flags: %i[featured] },
  { name_en: "Samsung Galaxy Flagship Phone",
    name_ru: "Флагманский смартфон Samsung Galaxy",
    name_ky: "Samsung Galaxy флагман смартфон",
    cat: "Smartphones", brand: "Samsung", price: 849.00, compare: 949.00, imgs: [ 6 ], flags: %i[on_sale new_arrival] },
  { name_en: "Bose QuietComfort Wireless Headphones",
    name_ru: "Беспроводные наушники Bose QuietComfort",
    name_ky: "Bose QuietComfort зымсыз кулакчындар",
    cat: "Headphones", brand: "Bose", price: 279.00, imgs: [ 7 ], flags: %i[featured] },
  { name_en: "Sony Noise-Cancelling Over-Ear Headphones",
    name_ru: "Полноразмерные наушники Sony с шумоподавлением",
    name_ky: "Sony ызы-чууну басаңдаткан толук өлчөмдөгү кулакчындар",
    cat: "Headphones", brand: "Sony", price: 348.00, compare: 399.00, imgs: [ 8 ], flags: %i[on_sale] },
  { name_en: "JBL Portable Bluetooth Speaker",
    name_ru: "Портативная Bluetooth-колонка JBL",
    name_ky: "JBL алып жүрүүчү Bluetooth динамиги",
    cat: "Speakers", brand: "JBL", price: 129.95, imgs: [ 9 ], flags: %i[new_arrival] },
  { name_en: "Bose Home Smart Speaker",
    name_ru: "Умная колонка Bose Home",
    name_ky: "Bose Home акылдуу динамиги",
    cat: "Speakers", brand: "Bose", price: 199.00, imgs: [ 10 ], flags: %i[featured] },
  { name_en: "Apple MacBook Ultrabook Laptop",
    name_ru: "Ноутбук-ультрабук Apple MacBook",
    name_ky: "Apple MacBook ультрабук ноутбугу",
    cat: "Laptops & Computers", brand: "Apple", price: 1299.00, imgs: [ 11 ], flags: %i[featured] },
  { name_en: "Logitech Wireless Gaming Mouse",
    name_ru: "Беспроводная игровая мышь Logitech",
    name_ky: "Logitech зымсыз оюн чычканы",
    cat: "Gaming", brand: "Logitech", price: 59.99, compare: 79.99, imgs: [ 12 ], flags: %i[on_sale] },
  { name_en: "Anker Fast Wireless Charging Pad",
    name_ru: "Быстрая беспроводная зарядка Anker",
    name_ky: "Anker тез зымсыз кубаттагыч",
    cat: "Smartphones", brand: "Anker", price: 39.99, imgs: [ 13 ], flags: %i[new_arrival] },
  { name_en: "Sony 4K Ultra HD Smart TV",
    name_ru: "Смарт-телевизор Sony 4K Ultra HD",
    name_ky: "Sony 4K Ultra HD акылдуу телевизор",
    cat: "TV & Home Theater", brand: "Sony", price: 899.00, compare: 1099.00, imgs: [ 14 ], flags: %i[featured on_sale] },
  { name_en: "Logitech HD Webcam for Streaming",
    name_ru: "HD веб-камера Logitech для стриминга",
    name_ky: "Logitech HD стриминг үчүн веб-камера",
    cat: "Cameras & Camcorders", brand: "Logitech", price: 89.99, imgs: [ 15 ], flags: [] },
  { name_en: "Apple Wireless Earbuds Pro",
    name_ru: "Беспроводные наушники Apple Earbuds Pro",
    name_ky: "Apple Earbuds Pro зымсыз кулакчындар",
    cat: "Headphones", brand: "Apple", price: 249.00, imgs: [ 1 ], flags: %i[new_arrival featured] },
  { name_en: "GoPro Fusion 360 Camera",
    name_ru: "Камера GoPro Fusion 360",
    name_ky: "GoPro Fusion 360 камерасы",
    cat: "Cameras & Camcorders", brand: "GoPro", price: 429.00, compare: 499.00, imgs: [ 3 ], flags: %i[on_sale] },
  { name_en: "Samsung Curved Gaming Monitor",
    name_ru: "Изогнутый игровой монитор Samsung",
    name_ky: "Samsung ийилген оюн монитору",
    cat: "Gaming", brand: "Samsung", price: 349.00, imgs: [ 4 ], flags: [] }
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
  ctr = cat_tr[spec[:cat]]
  p = Product.new(
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
  tr(p, :name, en: spec[:name_en], ru: spec[:name_ru], ky: spec[:name_ky])
  # Subtitle is "Brand · Category"; the brand stays put, the category localises.
  tr(p, :subtitle,
     en: "#{spec[:brand]} · #{ctr[:en]}",
     ru: "#{spec[:brand]} · #{ctr[:ru]}",
     ky: "#{spec[:brand]} · #{ctr[:ky]}")
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
# Reviews (author-written free text — stored as entered, not translated)
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
# Blog posts (title/subtitle/excerpt localised; rich-text body stays English)
# ---------------------------------------------------------------------------
puts "Creating blog posts…"
blog_covers = Dir.glob(BLOG_IMAGES.join("*.jpg")).map { |f| Pathname.new(f) }.first(6)
post_data = [
  { title_en: "5 Cameras That Will Level Up Your Photography in 2026",
    title_ru: "5 камер, которые поднимут вашу фотографию на новый уровень в 2026 году",
    title_ky: "2026-жылы фотографияңызды жаңы деңгээлге көтөрө турган 5 камера",
    sub_en: "From vlogging to pro shoots, here are our top picks.",
    sub_ru: "От влогов до профессиональной съёмки — вот наш топ.",
    sub_ky: "Влогдон профессионалдык тартууга чейин — биздин мыкты тандообуз.",
    exc_en: "Whether you're a beginner or a seasoned pro, the right camera makes all the difference.",
    exc_ru: "Новичок вы или опытный профессионал — правильная камера решает всё.",
    exc_ky: "Жаңы баштаган болобузбу же тажрыйбалуу профессионалбы — туура камера баарын чечет." },
  { title_en: "The Ultimate Smartwatch Buying Guide",
    title_ru: "Полное руководство по выбору смарт-часов",
    title_ky: "Акылдуу саат тандоо боюнча толук колдонмо",
    sub_en: "Everything you need to know before you buy.",
    sub_ru: "Всё, что нужно знать перед покупкой.",
    sub_ky: "Сатып алуудан мурун билиш керек болгон баары.",
    exc_en: "Battery life, health tracking, ecosystem — we break down what actually matters.",
    exc_ru: "Время работы, отслеживание здоровья, экосистема — разбираем, что действительно важно.",
    exc_ky: "Батареянын иштөө убактысы, ден соолукту көзөмөлдөө, экосистема — чын эле маанилүү нерселерди талдайбыз." },
  { title_en: "Wireless vs Wired Headphones: Which Should You Choose?",
    title_ru: "Беспроводные или проводные наушники: что выбрать?",
    title_ky: "Зымсыз же зымдуу кулакчындар: кайсынысын тандаш керек?",
    sub_en: "The eternal audiophile debate, settled.",
    sub_ru: "Вечный спор аудиофилов — наконец решён.",
    sub_ky: "Аудиофилдердин түбөлүктүү талашы — акыры чечилди.",
    exc_en: "Sound quality, convenience and price — a practical comparison.",
    exc_ru: "Качество звука, удобство и цена — практическое сравнение.",
    exc_ky: "Добуштун сапаты, ыңгайлуулук жана баа — практикалык салыштыруу." },
  { title_en: "How to Build the Perfect Home Office Setup",
    title_ru: "Как создать идеальное рабочее место дома",
    title_ky: "Үйдө идеалдуу иш ордун кантип түзүү керек",
    sub_en: "Productivity meets comfort.",
    sub_ru: "Продуктивность и комфорт вместе.",
    sub_ky: "Өндүрүмдүүлүк менен ыңгайлуулук чогуу.",
    exc_en: "The gadgets and accessories that make working from home a joy.",
    exc_ru: "Гаджеты и аксессуары, которые делают работу из дома в удовольствие.",
    exc_ky: "Үйдөн иштөөнү жагымдуу кылган гаджеттер жана аксессуарлар." }
]
post_data.each_with_index do |d, i|
  post = Post.new(author: [ owner, staff ].sample, published: true, published_at: (i + 1).days.ago)
  tr(post, :title,    en: d[:title_en], ru: d[:title_ru], ky: d[:title_ky])
  tr(post, :subtitle, en: d[:sub_en],   ru: d[:sub_ru],   ky: d[:sub_ky])
  tr(post, :excerpt,  en: d[:exc_en],   ru: d[:exc_ru],   ky: d[:exc_ky])
  post.body = "<p>#{d[:exc_en]}</p>" \
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
  { title_en: "Camera Season|Sale.", title_ru: "Сезон камер|Распродажа.", title_ky: "Камера мезгили|Арзандатуу.",
    sub_en: "Daily Deals", sub_ru: "Ежедневные предложения", sub_ky: "Күнүмдүк сунуштар",
    plabel_en: "Save up to", plabel_ru: "Скидка до", plabel_ky: "чейин арзандатуу",
    blabel_en: "Shop the deals", blabel_ru: "К предложениям", blabel_ky: "Сунуштарды көрүү",
    price: "$150.00", button_url: "/products?on_sale=1", img: "slide-1.jpg" },
  { title_en: "Smart Watches|Collection.", title_ru: "Смарт-часы|Коллекция.", title_ky: "Акылдуу сааттар|Коллекция.",
    sub_en: "New Arrivals", sub_ru: "Новинки", sub_ky: "Жаңы келгендер",
    plabel_en: "Starting at", plabel_ru: "От", plabel_ky: "баштап",
    blabel_en: "Discover now", blabel_ru: "Смотреть", blabel_ky: "Азыр көрүү",
    price: "$99.00", button_url: "/categories/smartwatches", img: "slide-2.jpg" }
]
slide_data.each_with_index do |d, i|
  slide = Slide.new(position: i, active: true, price: d[:price], button_url: d[:button_url])
  tr(slide, :title,        en: d[:title_en],  ru: d[:title_ru],  ky: d[:title_ky])
  tr(slide, :subtitle,     en: d[:sub_en],    ru: d[:sub_ru],    ky: d[:sub_ky])
  tr(slide, :price_label,  en: d[:plabel_en], ru: d[:plabel_ru], ky: d[:plabel_ky])
  tr(slide, :button_label, en: d[:blabel_en], ru: d[:blabel_ru], ky: d[:blabel_ky])
  slide.save!
  attach_image(slide.image, "demos/demo-3/slider/#{d[:img]}", d[:img])
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
puts "   Locales seeded: en, ru, ky"
puts "\n   Admin login → /session/new"
puts "   Owner:  admin@fabishop.test / password123"
puts "   Staff:  staff@fabishop.test / password123"
