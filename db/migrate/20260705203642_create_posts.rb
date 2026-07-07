class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :subtitle
      t.text :excerpt
      t.references :author, null: true, foreign_key: { to_table: :users }
      t.boolean :published, null: false, default: false
      t.datetime :published_at
      t.integer :views_count, null: false, default: 0

      t.timestamps
    end
    add_index :posts, :slug, unique: true
    add_index :posts, :published_at
  end
end
