
# app/models/order.rb
class Order < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # Validations
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending processing shipped delivered cancelled] }
  validates :payment_status, presence: true, inclusion: { in: %w[unpaid paid failed refunded] }

  # Enums
  enum :status, { pending: 0, processing: 1, shipped: 2, delivered: 3, cancelled: 4 }
  enum :payment_status, { unpaid: 0, paid: 1, failed: 2, refunded: 3 }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :paid, -> { where(payment_status: :paid) }

  # Methods
  def create_from_cart(cart, shipping_address)
    self.user = cart.user
    self.shipping_address = shipping_address
    self.total_amount = cart.total_price
    self.status = "pending"
    self.payment_status = "unpaid"

    ActiveRecord::Base.transaction do
      if save
        cart.cart_items.each do |cart_item|
          order_items.create!(
            product_id: cart_item.product_id,
            quantity: cart_item.quantity,
            price: cart_item.price
          )
        end
        cart.clear
        true
      else
        raise ActiveRecord::Rollback
        false
      end
    end
  rescue ActiveRecord::RecordInvalid
    false
  end
end
