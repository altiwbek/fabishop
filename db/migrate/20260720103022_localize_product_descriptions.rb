class LocalizeProductDescriptions < ActiveRecord::Migration[8.1]
  # Product descriptions become per-locale ActionText bodies. The existing single
  # `description` body holds English content, so re-point it at `description_en`.
  def up
    execute <<~SQL
      UPDATE action_text_rich_texts
      SET name = 'description_en'
      WHERE record_type = 'Product' AND name = 'description'
    SQL
  end

  def down
    execute <<~SQL
      UPDATE action_text_rich_texts
      SET name = 'description'
      WHERE record_type = 'Product' AND name = 'description_en'
    SQL
  end
end
