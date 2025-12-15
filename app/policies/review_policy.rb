# app/policies/review_policy.rb
class ReviewPolicy < ApplicationPolicy
  def destroy?
    user&.admin? || user == record.user
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
