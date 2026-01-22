# app/models/product.rb
class Product < ApplicationRecord
  # Associations
  belongs_to :category
  has_many :reviews, dependent: :destroy
  has_many :wishlists, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many_attached :images

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "description", "discount_percentage", "id", "is_active", "name", "price", "quantity_in_stock", "sku", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["category", "reviews", "wishlists", "cart_items", "order_items"]
  end

  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :sku, presence: true, uniqueness: true
  validates :quantity_in_stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category_id, presence: true
  validates :discount_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :images, content_type: { in: %w[image/jpeg image/png image/gif], message: "is not a valid image" },
                      size: { less_than: 5.megabytes, message: "should be less than 5MB" }, allow_nil: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :price_range, ->(min, max) { where(price: min..max) }
  scope :in_stock, -> { where("quantity_in_stock > ?", 0) }

  def self.search_with_filters(query, params)
    products = Product.active

    if query.present? && query != "*"
      term = "%#{query}%"
      products = products.where("name ILIKE ? OR description ILIKE ?", term, term)
    end

    products = products.by_category(params[:category]) if params[:category].present?
    
    if params[:min_price].present? && params[:max_price].present?
      products = products.price_range(params[:min_price].to_f, params[:max_price].to_f)
    end
    
    products = products.where(is_active: true)
    products = products.in_stock if params[:in_stock] == "true"

    products = products.page(params[:page] || 1).per(params[:per_page] || 20)
    
    products
  end

  # Methods
  def discount_price
    price - (price * discount_percentage / 100)
  end

  def in_stock?
    quantity_in_stock > 0
  end
end
