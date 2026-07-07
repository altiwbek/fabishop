# Session-backed shopping cart (no DB table). Stored as { "product_id" => qty }.
class Cart
  def initialize(session)
    @session = session
    @session[:cart] ||= {}
  end

  def raw = @session[:cart]

  def add(product_id, quantity = 1)
    id = product_id.to_s
    raw[id] = (raw[id].to_i + quantity.to_i).clamp(1, 99)
    @session[:cart] = raw
  end

  def set(product_id, quantity)
    id = product_id.to_s
    q = quantity.to_i
    if q <= 0
      remove(product_id)
    else
      raw[id] = q.clamp(1, 99)
    end
    @session[:cart] = raw
  end

  def remove(product_id)
    raw.delete(product_id.to_s)
    @session[:cart] = raw
  end

  def clear
    @session[:cart] = {}
  end

  def quantity_for(product_id) = raw[product_id.to_s].to_i

  # => [[product, qty], ...] preserving only still-existing products
  def line_items
    return [] if raw.empty?
    products = Product.where(id: raw.keys).index_by { |p| p.id.to_s }
    raw.filter_map { |id, qty| [ products[id], qty ] if products[id] }
  end

  def total_quantity = raw.values.sum(&:to_i)

  def total_price
    line_items.sum { |product, qty| product.price * qty }
  end

  def empty? = raw.empty?
end
