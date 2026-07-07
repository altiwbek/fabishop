class CreateSlides < ActiveRecord::Migration[8.1]
  def change
    create_table :slides do |t|
      t.string :title, null: false
      t.string :subtitle
      t.string :price_label
      t.string :price
      t.string :button_label
      t.string :button_url
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :slides, :position
  end
end
