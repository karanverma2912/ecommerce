# app/models/category.rb
class Category < ApplicationRecord
  # Associations
  has_many :products, dependent: :destroy
  has_one_attached :image

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :slug, uniqueness: true, allow_nil: true
  validates :image, content_type: { in: %w[image/jpeg image/png image/gif], message: "is not a valid image" },
                     size: { less_than: 5.megabytes, message: "should be less than 5MB" }, allow_nil: true

  # Callbacks
  before_save :generate_slug

  # Scopes
  scope :active, -> { where(is_active: true) }

  private

  def generate_slug
    self.slug ||= name.downcase.gsub(/[^a-z0-9]+/, "-").chomp("-")
  end
end
