# app/models/cart_item.rb
class CartItem < ApplicationRecord
  # Associations
  belongs_to :cart
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }
end
