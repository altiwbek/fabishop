class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # owner  -> the store owner, full access
  # staff  -> employees who manage catalog & content
  enum :role, { staff: 0, owner: 1 }, default: :staff

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true

  # Persisted UI language. Blank means "no explicit choice yet" — fall back to
  # the browser/Accept-Language detection handled in ApplicationController.
  validates :locale,
    inclusion: { in: ->(_) { I18n.available_locales.map(&:to_s) } },
    allow_blank: true

  def display_name
    name.presence || email_address.split("@").first
  end

  def initials
    display_name.split.map(&:first).first(2).join.upcase
  end
end
