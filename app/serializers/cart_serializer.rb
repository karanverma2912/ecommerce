
# app/serializers/cart_serializer.rb
class CartSerializer < ActiveModel::Serializer
  attributes :id, :total_price, :items_count, :items

  has_many :cart_items, serializer: CartItemSerializer

  def items_count
    object.cart_items.count
  end
end
