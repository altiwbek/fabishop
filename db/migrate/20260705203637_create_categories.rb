class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.boolean :featured, null: false, default: false
      t.references :parent, foreign_key: { to_table: :categories }
      t.integer :products_count, null: false, default: 0

      t.timestamps
    end
    add_index :categories, :slug, unique: true
    add_index :categories, :position
  end
end
