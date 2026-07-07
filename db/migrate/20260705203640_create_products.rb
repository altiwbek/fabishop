class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :subtitle
      t.string :sku
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.decimal :compare_at_price, precision: 10, scale: 2
      t.integer :stock, null: false, default: 0
      t.references :category, null: false, foreign_key: true
      t.references :brand, null: true, foreign_key: true
      t.boolean :published, null: false, default: false
      t.boolean :featured, null: false, default: false
      t.boolean :new_arrival, null: false, default: false
      t.boolean :on_sale, null: false, default: false
      t.datetime :published_at
      t.integer :views_count, null: false, default: 0
      t.integer :reviews_count, null: false, default: 0
      t.decimal :rating, precision: 3, scale: 2, null: false, default: 0

      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true
    add_index :products, :published
    add_index :products, :featured
  end
end
