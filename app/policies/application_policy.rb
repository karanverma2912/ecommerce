
# app/policies/application_policy.rb
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user&.admin?
  end

  def new?
    create?
  end

  def update?
    user&.admin? || user == record.user
  end

  def edit?
    update?
  end

  def destroy?
    user&.admin? || user == record.user
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define the resolve method in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
