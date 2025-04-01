class FillAuthorizationsState < ActiveRecord::Migration[8.0]
  # rubocop:disable Rails/SkipsModelValidations
  def up
    Authorization.where(revoked: true).update_all(state: :revoked)
    Authorization.where(revoked: false).update_all(state: :obsolete)
    Authorization.where(id: last_authorizations_by_stage_ids).update_all(state: :active)
  end
  # rubocop:enable Rails/SkipsModelValidations

  def down
  end

  private

  # https://claude.ai/share/a27acb83-d2d0-4f73-9232-4e0cbc479274
  def last_authorizations_by_stage_ids
    subquery = Authorization
      .select('id, request_id, form_uid, created_at,
               ROW_NUMBER() OVER (PARTITION BY request_id, form_uid ORDER BY created_at DESC) as rn')
      .to_sql

    result = Authorization.connection.execute(<<-SQL.squish)
      SELECT request_id, array_agg(id) as authorization_ids
      FROM (#{subquery}) as latest_auths
      WHERE rn = 1
      GROUP BY request_id
    SQL

    result.map { |row| row['authorization_ids'].tr('{}', '').split(',').map(&:to_i) }.flatten
  end
end
