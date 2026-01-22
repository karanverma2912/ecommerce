# app/models/review.rb
class Review < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :product
  has_many :comments, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  # Validations
  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :comment, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :product_id, message: "can only review a product once" }

  # Scopes
  scope :by_product, ->(product_id) { where(product_id: product_id) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :recent, -> { order(created_at: :desc) }
end
