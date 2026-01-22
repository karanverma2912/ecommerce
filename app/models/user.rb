# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :reviews, dependent: :destroy
  has_many :wishlists, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one_attached :avatar

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :first_name, :last_name, presence: true
  validates :avatar, content_type: { in: %w[image/jpeg image/png image/gif], message: "is not a valid image" },
                      size: { less_than: 5.megabytes, message: "should be less than 5MB" }, allow_nil: true

  # Scopes
  scope :admins, -> { where(is_admin: true) }
  scope :regular_users, -> { where(is_admin: false) }

  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    is_admin
  end
end
