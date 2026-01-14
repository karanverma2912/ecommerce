class CleanupUnverifiedUsersJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Delete users who are unverified and created more than 24 hours ago
    User.where(email_verified: false)
        .where('created_at < ?', 24.hours.ago)
        .destroy_all
  end
end
