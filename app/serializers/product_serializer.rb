
# app/serializers/product_serializer.rb
class ProductSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :description, :price, :discount_percentage, :discount_price, :sku, :quantity_in_stock, :in_stock, :category_id, :images_urls, :created_at

  def discount_price
    object.discount_price
  end

  def images_urls
    object.images.map { |image| url_for(image) }
  end

  def in_stock
    object.in_stock?
  end
end
