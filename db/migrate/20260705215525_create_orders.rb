class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :number, null: false
      t.string :token, null: false
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :address
      t.string :city
      t.string :postal_code
      t.string :country
      t.integer :status, null: false, default: 0
      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: 0
      t.decimal :shipping, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0
      t.text :notes

      t.timestamps
    end
    add_index :orders, :number, unique: true
    add_index :orders, :token, unique: true
    add_index :orders, :status
  end
end
