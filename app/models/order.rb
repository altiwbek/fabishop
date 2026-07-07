class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  STATUSES = { pending: 0, paid: 1, shipped: 2, delivered: 3, cancelled: 4 }.freeze
  enum :status, STATUSES, default: :pending

  before_validation :assign_identifiers, on: :create

  validates :number, :token, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, :address, :city, presence: true

  scope :recent, -> { order(created_at: :desc) }

  FREE_SHIPPING_THRESHOLD = 99
  SHIPPING_FLAT = 9.99

  def to_param = token

  def customer_name = [ first_name, last_name ].compact_blank.join(" ").presence || email

  def item_count = order_items.sum(:quantity)

  # Build order lines + totals from a Cart, snapshotting price/name.
  def build_from_cart(cart)
    cart.line_items.each do |product, qty|
      order_items.build(
        product: product,
        product_name: product.name,
        sku: product.sku,
        unit_price: product.price,
        quantity: qty
      )
    end
    recalculate_totals
  end

  def recalculate_totals
    self.subtotal = order_items.sum { |i| i.unit_price * i.quantity }
    self.shipping = (subtotal >= FREE_SHIPPING_THRESHOLD || subtotal.zero?) ? 0 : SHIPPING_FLAT
    self.total = subtotal + shipping
  end

  def status_color
    { "pending" => :yellow, "paid" => :indigo, "shipped" => :indigo,
      "delivered" => :green, "cancelled" => :red }[status] || :gray
  end

  private

  def assign_identifiers
    self.token ||= SecureRandom.urlsafe_base64(16)
    self.number ||= generate_number
  end

  def generate_number
    loop do
      candidate = "DRD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}"
      break candidate unless Order.exists?(number: candidate)
    end
  end
end
