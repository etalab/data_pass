module Molecules::Instruction::Breadcrumb
  private

  def formulaires_breadcrumb_item
    { label: I18n.t('layouts.header.menu.instruction.formulaires'),
      href: helpers.instruction_authorization_definitions_path }
  end

  def authorization_definition_breadcrumb_item(link: true)
    item = { label: authorization_definition.name_with_stage }
    item[:href] = helpers.instruction_authorization_definition_path(authorization_definition) if link
    item
  end
end
