# frozen_string_literal: true

class ProgramPolicy < ApplicationPolicy
  def create?
    user.committer?
  end

  def update?
    user.committer?
  end

  def hide?
    user.role.admin?
  end

  def destroy?
    user.role.admin?
  end
end
