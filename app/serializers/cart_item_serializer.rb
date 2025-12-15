
# app/serializers/cart_item_serializer.rb
class CartItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :price, :subtotal, :product

  def subtotal
    object.quantity * object.price
  end

  def product
    ProductSerializer.new(object.product).as_json
  end
end
