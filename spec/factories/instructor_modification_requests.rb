FactoryBot.define do
  factory :instructor_modification_request do
    reason { 'Veuillez inclure une preuve de compétence en calligraphie, conformément à la nouvelle directive interne visant à améliorer la qualité visuelle des documents manuscrits officiels' }
    authorization_request factory: %i[authorization_request], state: 'changes_requested'
  end
end
