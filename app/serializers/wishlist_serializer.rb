# app/serializers/wishlist_serializer.rb
class WishlistSerializer < ActiveModel::Serializer
  attributes :id, :product

  def product
    ProductSerializer.new(object.product).as_json
  end
end
