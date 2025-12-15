# app/models/wishlist.rb
class Wishlist < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :product

  # Validations
  validates :user_id, uniqueness: { scope: :product_id, message: "product already in wishlist" }
end
