
# app/policies/product_policy.rb
class ProductPolicy < ApplicationPolicy
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
