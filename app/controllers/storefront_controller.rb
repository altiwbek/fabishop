# Base controller for the public-facing storefront. Everything here is
# accessible without logging in; login is only for the admin CRM.
class StorefrontController < ApplicationController
  allow_unauthenticated_access
  layout "storefront"

  helper_method :current_cart, :current_wishlist, :nav_categories, :nav_collections

  private

  def current_cart
    @current_cart ||= Cart.new(session)
  end

  def current_wishlist
    @current_wishlist ||= Wishlist.new(session)
  end

  def nav_categories
    @nav_categories ||= Category.roots.ordered.includes(:children).to_a
  end

  def nav_collections
    @nav_collections ||= Collection.active.ordered.to_a
  end

  # Track the last 8 viewed product ids in the session.
  def track_recently_viewed(product)
    ids = (session[:recently_viewed] || [])
    ids.delete(product.id)
    ids.unshift(product.id)
    session[:recently_viewed] = ids.first(8)
  end

  def recently_viewed_products(exclude: nil)
    ids = (session[:recently_viewed] || []).reject { |id| id == exclude&.id }
    return Product.none if ids.empty?
    Product.published.where(id: ids).index_by(&:id).values_at(*ids).compact
  end
end
