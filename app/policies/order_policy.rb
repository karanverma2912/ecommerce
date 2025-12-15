# app/policies/order_policy.rb
class OrderPolicy < ApplicationPolicy
  def show?
    user&.admin? || user == record.user
  end

  def update_status?
    user&.admin?
  end

  class Scope < Scope
    def resolve
      user&.admin? ? scope.all : scope.where(user_id: user.id)
    end
  end
end
