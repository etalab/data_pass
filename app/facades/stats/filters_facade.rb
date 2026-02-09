class Stats::FiltersFacade
  def to_h
    {
      providers: providers_list,
      types: types_list,
      forms: forms_list
    }
  end

  private

  def providers_list
    DataProvider.all.map do |provider|
      { slug: provider.slug, name: provider.name }
    end
  end

  def types_list
    providers_by_slug = DataProvider.all.index_by(&:slug)

    AuthorizationDefinition.all.map do |definition|
      provider = providers_by_slug[definition.provider_slug]

      {
        class_name: definition.authorization_request_class.name,
        name: definition.name_with_stage,
        provider_slug: provider&.slug
      }
    end
  end

  def forms_list
    AuthorizationRequestForm.all.map do |form|
      {
        uid: form.uid,
        name: form.name,
        authorization_type: form.authorization_request_class.name
      }
    end
  end
end
