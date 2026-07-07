# Session-backed wishlist (no DB table). Stored as an array of product ids.
class Wishlist
  def initialize(session)
    @session = session
    @session[:wishlist] ||= []
  end

  def raw = @session[:wishlist]

  def add(product_id)
    id = product_id.to_i
    raw << id unless raw.include?(id)
    @session[:wishlist] = raw
  end

  def remove(product_id)
    raw.delete(product_id.to_i)
    @session[:wishlist] = raw
  end

  def toggle(product_id)
    include?(product_id) ? remove(product_id) : add(product_id)
  end

  def include?(product_id)
    id = product_id.respond_to?(:id) ? product_id.id : product_id.to_i
    raw.include?(id)
  end

  def products
    return Product.none if raw.empty?
    Product.where(id: raw)
  end

  def count = raw.size
  def empty? = raw.empty?
end
