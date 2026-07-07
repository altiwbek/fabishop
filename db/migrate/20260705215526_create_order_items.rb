class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: true, foreign_key: { on_delete: :nullify }
      t.string :product_name, null: false
      t.string :sku
      t.decimal :unit_price, precision: 10, scale: 2, null: false, default: 0
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
  end
end
