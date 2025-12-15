# app/serializers/user_serializer.rb
class UserSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :email, :first_name, :last_name, :full_name, :phone, :address, :city, :state, :zip_code, :country, :is_admin, :avatar_url, :created_at

  def full_name
    "#{object.first_name} #{object.last_name}"
  end

  def avatar_url
    object.avatar.attached? ? url_for(object.avatar) : nil
  end
end
