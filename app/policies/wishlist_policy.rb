class WishlistPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  def index?
    true
  end

  def add?
    true
  end

  def remove?
    record.user_id == user.id
  end
end
