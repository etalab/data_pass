class Admin::UserRightPolicy < Instruction::UserRightPolicy
  def enabled?
    user.admin?
  end

  private

  def authority
    @authority ||= Rights::AdminAuthority.new(user)
  end
end
