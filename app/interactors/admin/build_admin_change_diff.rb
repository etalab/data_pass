class Admin::BuildAdminChangeDiff < ApplicationInteractor
  def call
    return context.diff ||= {} unless context.block

    build_diff_from_block
  end

  private

  def build_diff_from_block
    snapshot = authorization_request.data.deep_dup
    execute_block
    authorization_request.reload
    context.diff = compute_diff(snapshot, authorization_request.data)
  end

  def execute_block
    context.block.call(authorization_request)
    raise I18n.t('admin.build_admin_change_diff.unsaved_changes') if authorization_request.changed?
  end

  def authorization_request
    context.authorization_request
  end

  def compute_diff(before, after)
    (before.keys | after.keys).each_with_object({}) do |key, diff|
      old_val = before[key]
      new_val = after[key]
      diff[key] = [old_val, new_val] if old_val != new_val
    end
  end
end
