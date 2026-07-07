class CreateBrands < ActiveRecord::Migration[8.1]
  def change
    create_table :brands do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :website
      t.integer :position, null: false, default: 0
      t.integer :products_count, null: false, default: 0

      t.timestamps
    end
    add_index :brands, :slug, unique: true
  end
end
