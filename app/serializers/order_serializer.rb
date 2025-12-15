# app/serializers/order_serializer.rb
class OrderSerializer < ActiveModel::Serializer
  attributes :id, :total_amount, :status, :payment_status, :payment_method, :created_at, :order_date

  def order_date
    object.created_at.strftime("%B %d, %Y")
  end
end
