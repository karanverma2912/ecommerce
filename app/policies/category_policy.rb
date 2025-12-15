
# app/policies/category_policy.rb
class CategoryPolicy < ApplicationPolicy
  def create?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def destroy?
    user&.admin?
  end

  class Scope < Scope
    def resolve
      scope.where(is_active: true)
    end
  end
end
