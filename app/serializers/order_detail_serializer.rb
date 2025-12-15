# app/serializers/order_detail_serializer.rb
class OrderDetailSerializer < OrderSerializer
  attributes :shipping_address, :updated_at

  has_many :order_items, serializer: OrderItemSerializer
end
