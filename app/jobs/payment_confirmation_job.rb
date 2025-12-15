# app/jobs/payment_confirmation_job.rb
class PaymentConfirmationJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    OrderConfirmationMailer.with(order: order).payment_confirmed.deliver_later
    # Decrement product quantity in stock
    order.order_items.each do |item|
      product = item.product
      product.update(quantity_in_stock: product.quantity_in_stock - item.quantity)
    end
  end
end
