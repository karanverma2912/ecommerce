# app/models/product.rb
class Product < ApplicationRecord
  include Searchkick

  def self.search_with_filters(query, params)
    filters = { is_active: true }
    filters[:category_name] = params[:category] if params[:category].present?
    filters[:price] = (params[:min_price].to_f..params[:max_price].to_f) if params[:min_price].present? && params[:max_price].present?
    filters[:in_stock] = true if params[:in_stock] == "true"

    search(
      query.presence || "*",
      where: filters,
      page: params[:page] || 1,
      per_page: params[:per_page] || 20,
      load: false
    )
  end

  # Associations
  belongs_to :category
  has_many :reviews, dependent: :destroy
  has_many :wishlists, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many_attached :images

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

  # SearchKick options
  searchkick word_start: [ :name, :description ]

  # , text_start: [ :category_name ],
  #            merge_duplicates: true,
  #            settings: {
  #              analysis: {
  #                analyzer: {
  #                  default: {
  #                    type: "standard"
  #                  }
  #                }
  #              }
  #            }

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :price_range, ->(min, max) { where(price: min..max) }
  scope :in_stock, -> { where("quantity_in_stock > ?", 0) }

  # Methods
  def discount_price
    price - (price * discount_percentage / 100)
  end

  def search_data
    {
      name: name,
      description: description,
      category_name: category.name,
      price: price,
      discount_percentage: discount_percentage,
      in_stock: quantity_in_stock > 0,
      created_at: created_at
    }
  end

  def in_stock?
    quantity_in_stock > 0
  end
end
