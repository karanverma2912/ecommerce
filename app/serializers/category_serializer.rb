
# app/serializers/category_serializer.rb
class CategorySerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name, :description, :slug, :image_url, :is_active, :created_at

  def image_url
    object.image.attached? ? url_for(object.image) : nil
  end
end
