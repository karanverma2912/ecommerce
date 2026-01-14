# app/models/cart.rb
class Cart < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def items
    cart_items
  end

  # Methods
  def add_product(product, quantity = 1)
    item = cart_items.find_or_initialize_by(product_id: product.id)
    item.quantity = (item.quantity || 0) + quantity.to_i
    item.price = product.price
    item.save!
    recalculate_total!
  end

  def remove_product(product_id)
    cart_items.where(product_id: product_id).destroy_all
    recalculate_total!
  end

  def clear
    cart_items.destroy_all
    recalculate_total!
  end

  def recalculate_total!
    update_column(:total_price, cart_items.sum("price * quantity"))
  end
end
