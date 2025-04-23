class PostMigrationInspector
  include LocalDatabaseUtils

  def perform
    Rails.logger.silence do
      check("New authorizations (> 100k) not from DGFIP (exists for others with reopening)", new_authorizations_not_from_dgfip?)
      check("All DGFIP productions not editor (unique) have only one valid sandbox authorization", authorization_request_production_not_editor_has_at_least_one_valid_sandbox_authorization?)
      check("DGFIP v1 sandbox enrollments approved once exists within authorizations", dgfip_sandbox_valid_v1_v2_match?)
      check("DGFIP v1 sandbox enrollments not approved once exists within authorization requests and not in authorizations", dgfip_sandbox_other_v1_v2_match?)
      check("DGFIP v1 unique enrollments have authorization requests, authorizations for approved once", dgfip_unique_v1_v2_match?)
      check("DGFIP v1 productions have authorization requests, at least 2 authorizations (sandbox, production) for approved once", dgfip_production_v1_v2_match?)
      check("All authorizations approved or reopened have a valid authorization", authorization_requests_have_valid_authorization?)
      check("All DGFIP productions have a form uid from production (-production or -editeur)", authorization_request_production_have_a_form_uid_from_production?)
      check("All DGFIP productions non-orphan (i.e. a copy exists and is legit) have an intitule", authorization_request_production_have_an_intitule?)
    end
  end

  private

  def check(text, bool)
    print "### #{text}: #{bool ? '✅' : '❌'}\n"

    return if bool

    # byebug
  end

  def new_authorizations_not_from_dgfip?
    extra_authorization_requests = Authorization.where(id: (100_000..))
    # log("Authorization > 100k: #{extra_authorization_requests.group(:authorization_request_class).count}\n")

    (extra_authorization_requests.pluck(:authorization_request_class) & dgfip_definitions.map(&:authorization_request_class)).empty?
  end

  def authorization_request_production_not_editor_has_at_least_one_valid_sandbox_authorization?
    production_types = dgfip_production_definitions.map(&:authorization_request_class).map(&:to_s)

    bad_requests = AuthorizationRequest
      .where(type: production_types)
      .where("authorization_requests.state = 'approved'")
      .where.not("authorization_requests.form_uid ILIKE ?", "%-editeur")
      .left_joins(:authorizations)
      .group("authorization_requests.id")
      .having(<<~SQL)
        COUNT(authorizations.id) FILTER (WHERE authorizations.state = 'active' and authorizations.authorization_request_class ilike '%Sandbox') = 0
      SQL

    log("AuthorizationRequest with wrong number of authorizations (#{bad_requests.count}): #{bad_requests.pluck(:id)}\n\n\n") if bad_requests.any?

    bad_requests.empty?
  end

  def authorization_request_production_have_an_intitule?
    bad_requests = AuthorizationRequest
      .where(type: dgfip_production_definitions.map(&:authorization_request_class).map(&:to_s))
      .where.not("data ? 'intitule'")

    bad_authorizations = Authorization
      .where(request_id: bad_requests.pluck(:id))
      .where.not("data ? 'intitule'")

    bad_requests = clean_requests_with_another_request_in_production(bad_requests)
    bad_requests = AuthorizationRequest.where(id: bad_requests.map(&:id))

    log("AuthorizationRequest with no intitule (#{bad_requests.count}): #{bad_requests.pluck(:id, :type, :state)}\n\n\n") if bad_requests.any?
    log("Authorization with no intitule (#{bad_authorizations.count}): #{bad_authorizations.pluck(:id, :authorization_request_class, :state)}\n\n\n") if bad_authorizations.any?

    bad_requests.empty? && bad_authorizations.empty?
  end

  def clean_requests_with_another_request_in_production(bad_requests)
    bad_requests.to_a.reject do |request|
      sandbox_request_id = database.execute("select previous_enrollment_id from enrollments where id = #{request.id}")[0][0]

      Authorization.find(sandbox_request_id).request.definition.stage.type == 'production'
    end
  end

  def authorization_request_production_have_a_form_uid_from_production?
    authorization_requests = AuthorizationRequest.where(
      type: dgfip_production_definitions.map(&:authorization_request_class).map(&:to_s),
    ).where(
      "not (form_uid ilike '%-editeur' or form_uid ilike '%-production')"
    )

    log("AuthorizationRequest with no valid form_uid (#{authorization_requests.count}): #{authorization_requests.pluck(:id, :type, :form_uid)}\n\n\n") if authorization_requests.count.positive?

    authorization_requests.count.zero?
  end

  def authorization_requests_have_valid_authorization?
    bad_requests = AuthorizationRequest
      .where("reopened_at IS NOT NULL OR authorization_requests.state = 'approved'")
      .left_joins(:authorizations)
      .group("authorization_requests.id")
      .having(<<~SQL)
        COUNT(authorizations.id) FILTER (WHERE authorizations.state = 'active') != 1
      SQL

    log("AuthorizationRequest missing valid authorization: #{bad_requests.pluck(:id)}\n") if bad_requests.any?

    bad_requests.empty?
  end

  def dgfip_sandbox_valid_v1_v2_match?
    v1_sandbox_ids = database.execute("select id from enrollments where target_api like '%_sandbox' and status in ('validated', 'revoked')").flatten

    sandbox_missing_ids = v1_sandbox_ids - Authorization.where("authorization_request_class like '%Sandbox'").pluck(:id)
    # FIXME foreign organizations, will be fixed in the future
    sandbox_missing_ids -= [4441, 4442, 6522]
    log("Missing ids for sandbox (#{sandbox_missing_ids.count}): #{sandbox_missing_ids}\n") if sandbox_missing_ids.any?

    sandbox_missing_ids.blank?
  end

  def dgfip_sandbox_other_v1_v2_match?
    v1_sandbox_ids = database.execute("select id from enrollments where target_api like '%_sandbox' and status not in ('validated', 'revoked')").flatten
    sandbox_request_missing_ids = v1_sandbox_ids - AuthorizationRequest.where("type like '%Sandbox'").pluck(:id)

    log("Missing ids for requests sandbox (#{sandbox_request_missing_ids.count}): #{sandbox_request_missing_ids}\n") if sandbox_request_missing_ids.any?

    sandbox_authorizations = Authorization.where(request_id: sandbox_request_missing_ids)

    log("Authorizations exists for sandbox (#{sandbox_authorizations.count}): #{sandbox_authorizations.pluck(:id)}\n") if sandbox_authorizations.any?

    sandbox_request_missing_ids -= sandbox_authorizations.pluck(:id)

    log("Missing ids for requests sandbox (#{sandbox_request_missing_ids.count}): #{sandbox_request_missing_ids}\n") if sandbox_request_missing_ids.any?

    sandbox_request_missing_ids.blank? && sandbox_authorizations.count.zero?
  end

  def dgfip_unique_v1_v2_match?
    v1_unique_validated_ids = database.execute("select id from enrollments where target_api like '%_unique' and status in ('validated', 'revoked')").flatten

    authorizations = Authorization.where(id: v1_unique_validated_ids)

    missing_authorizations = v1_unique_validated_ids - authorizations.pluck(:id)

    log("Missing authorizations ids for unique (#{missing_authorizations.count}): #{missing_authorizations}\n") if missing_authorizations.any?

    v1_unique_ids = database.execute("select id from enrollments where target_api like '%_unique'").flatten

    requests = AuthorizationRequest.where(id: v1_unique_ids)

    missing_requests = v1_unique_ids - requests.pluck(:id)

    log("Missing requests ids for unique (#{missing_requests.count}): #{missing_requests}\n") if missing_requests.any?

    missing_requests.blank? && missing_authorizations.blank?
  end

  def dgfip_production_v1_v2_match?
    v1_production_validated_ids = database.execute("select id from enrollments where target_api like '%_production' and status in ('validated', 'revoked')").flatten

    requests = AuthorizationRequest.includes(:authorizations).where(id: v1_production_validated_ids)

    requests = requests.to_a.select do |request|
      valid_authorizations = request.authorizations.where(state: 'active')

      valid_authorizations.pluck(:authorization_request_class).uniq.count < 2
    end

    log("Production requests validated without enough authorizations (#{requests.count}): #{requests.pluck(:id, :type)}\n") if requests.any?

    requests.blank?

    # XXX a priori que des demandes qui ont des demandes plus récentes more_recent_ongoing_production? renvoi true
    data = database.execute("select id, previous_enrollment_id from enrollments where target_api like '%_production'")
    # byebug

    requests = AuthorizationRequest.where(id: data.map { |d| d[0] })
    missing_request_ids = data.map { |d| d[0] }- requests.pluck(:id)

    data = data.reject { |d| missing_request_ids.exclude?(d[0]) }
    data = clean_requests_when_more_recent_exists?(data)
    missing_request_ids = data.map { |d| d[0] }

    # FIXME foreign organizations, will be fixed in the future
    missing_request_ids -= [4649, 4650, 7356, 7367]

    log("Missing requests ids for production (#{missing_request_ids.count}): #{missing_request_ids}\n") if missing_request_ids.any?

    requests.blank? && missing_request_ids.blank?
  end

  def clean_requests_when_more_recent_exists?(data)
    sandbox_authorization_already_linked_to_another_request = Authorization.where(id: data.map { |d| d[1] }).pluck(:id)

    data.reject do |d|
      sandbox_authorization_already_linked_to_another_request.include?(d[1])
    end
  end

  def format_row(row)
    JSON.parse(row[-1]).to_h
  end

  def dgfip_definitions
    @dgfip_definitions ||= DataProvider.find('dgfip').authorization_definitions
  end

  def dgfip_production_definitions
    @dgfip_production_definitions ||= dgfip_definitions.select { |definition| definition.stage.type == 'production' }
  end

  def log(text)
    print text unless ENV['SILENT'].present?
  end
end
