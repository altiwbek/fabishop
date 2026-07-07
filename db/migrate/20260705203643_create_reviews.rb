class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :product, null: false, foreign_key: true
      t.string :author_name, null: false
      t.string :author_email
      t.integer :rating, null: false, default: 5
      t.string :title
      t.text :body
      t.boolean :approved, null: false, default: false
      t.integer :helpful_count, null: false, default: 0

      t.timestamps
    end
    add_index :reviews, :approved
  end
end
