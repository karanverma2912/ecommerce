class AddIndexesToProductsAndReviews < ActiveRecord::Migration[8.1]
  def change
    add_index :products, :price
    add_index :products, :is_active
    add_index :reviews, :rating
  end
end
