# rubocop:disable Style/FormatStringToken
class Seeds
  class MessageTemplates
    def self.create
      create_api_entreprise_modification_request_templates
      create_api_entreprise_refusal_templates
      create_api_particulier_refusal_templates
    end

    def self.create_api_entreprise_modification_request_templates
      MessageTemplate.create!(
        title: 'Cadre juridique incomplet',
        authorization_definition_uid: 'api_entreprise',
        template_type: :modification_request,
        content: "Le cadre juridique que vous avez fourni n'est pas suffisamment précis pour que nous puissions instruire votre demande. Merci de préciser :\n- La base légale exacte qui vous autorise à traiter ces données\n- L'article de loi ou le règlement qui s'applique à votre traitement\n\nVous pouvez modifier votre demande directement sur DataPass."
      )

      MessageTemplate.create!(
        title: 'Périmètre trop large',
        authorization_definition_uid: 'api_entreprise',
        template_type: :modification_request,
        content: "Le périmètre des données demandées nous semble trop large au regard de la finalité indiquée. Merci de :\n- Justifier précisément chaque donnée demandée\n- Réduire le périmètre aux seules données strictement nécessaires\n- Préciser les cas d'usage concrets de chaque donnée\n\nVous pouvez consulter et modifier votre demande ici : %{demande_url}"
      )
    end

    def self.create_api_entreprise_refusal_templates
      MessageTemplate.create!(
        title: 'Finalité non éligible',
        authorization_definition_uid: 'api_entreprise',
        template_type: :refusal,
        content: "Après étude, nous sommes au regret de vous informer que votre demande ne peut être acceptée. La finalité indiquée ne correspond pas aux cas d'usage autorisés pour API Entreprise, qui sont réservés aux démarches administratives dans le cadre d'une mission de service public.\n\nAPI Entreprise ne peut être utilisée à des fins commerciales, de prospection ou de constitution de fichiers.\n\nPour plus d'informations sur les cas d'usage éligibles, consultez notre documentation."
      )
    end

    def self.create_api_particulier_refusal_templates
      MessageTemplate.create!(
        title: 'Organisation non habilitée',
        authorization_definition_uid: 'api_particulier',
        template_type: :refusal,
        content: "Après vérification, votre organisation n'est pas habilitée à accéder à API Particulier. L'accès à cette API est réservé aux administrations et organismes chargés d'une mission de service public.\n\nLes entreprises privées, même si elles opèrent pour le compte d'une administration, ne peuvent obtenir directement un accès. C'est l'administration elle-même qui doit faire la demande.\n\nConsultez votre demande ici : %{demande_url}"
      )
    end
  end
end
# rubocop:enable Style/FormatStringToken
