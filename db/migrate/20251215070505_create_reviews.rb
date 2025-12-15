class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :rating, null: false, default: 0
      t.text :comment

      t.timestamps
    end

    add_index :reviews, [ :user_id, :product_id ], unique: true
  end
end
