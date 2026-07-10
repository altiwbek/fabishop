class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Order by a Mobility-translated attribute using the current locale's value,
  # falling back to the English value (then empty) so rows never sort as NULL.
  # `attribute` is always a symbol/string from our own code, never user input.
  def self.order_by_translation(attribute)
    locale = Mobility.locale
    order(Arel.sql(
      "COALESCE(NULLIF(translations -> '#{locale}' ->> '#{attribute}', ''), " \
      "translations -> 'en' ->> '#{attribute}', '')"
    ))
  end
end
