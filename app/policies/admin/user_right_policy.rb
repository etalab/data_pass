class Admin::UserRightPolicy < Instruction::UserRightPolicy
  def enabled?
    user.admin?
  end

  def edit?
    enabled? && record != user
  end
end
