class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  CATEGORIES = %w[order_update promotion system_alert security inventory].freeze

  validates :title, presence: true
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    update!(read_at: Time.current)
  end

  def read?
    read_at.present?
  end

  def unread?
    read_at.nil?
  end
end
