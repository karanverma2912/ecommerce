class CartPolicy < ApplicationPolicy
  def show?
    user_owns_record?
  end

  def add_item?
    user_owns_record?
  end

  def update_item?
    user_owns_record?
  end

  def remove_item?
    user_owns_record?
  end

  def clear?
    user_owns_record?
  end

  private

  def user_owns_record?
    user.present? && record.user == user
  end
end
