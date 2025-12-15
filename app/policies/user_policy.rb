
# app/policies/user_policy.rb
class UserPolicy < ApplicationPolicy
  def update?
    user&.admin? || user == record
  end

  def destroy?
    user&.admin? || user == record
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
