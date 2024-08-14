def applicant_session(authorization_request)
  return @applicant_session if @applicant_session.present?

  @applicant_session = Capybara::Session.new(Capybara.default_driver, Rails.application)

  Capybara.using_session(@applicant_session) do
    mock_mon_compte_pro(authorization_request.applicant)
    step 'je me connecte'
  end

  @applicant_session
end
