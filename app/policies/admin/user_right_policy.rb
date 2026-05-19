class Admin::UserRightPolicy < Instruction::UserRightPolicy
  def enabled?
    user.admin?
  end

  def edit?
    enabled?
  end
end
