def setting_block_testing(block_title, &)
  settings_block = find('.settings-block__title', text: block_title).ancestor('.settings-block')

  within(settings_block, &)
end

Alors(/l'interrupteur "([^"]+)" dans le bloc de paramètres "([^"]+)" est (activé|désactivé)/) do |switch_label, block_title, state|
  setting_block_testing(block_title) do
    switch_label = find('.fr-toggle__label', text: switch_label)
    switch = switch_label.find(:xpath, '..').find(:css, '.fr-toggle__input', visible: false)

    if state == 'activé'
      expect(switch).to be_checked
    else
      expect(switch).not_to be_checked
    end
  end
end

Quand(/je clique sur l'interrupteur "([^"]+)" dans le bloc de paramètres "([^"]+)"/) do |switch_label, block_title|
  setting_block_testing(block_title) do
    switch_label = find('.fr-toggle__label', text: switch_label)
    switch = switch_label.find(:xpath, '..').find(:css, '.fr-toggle__input', visible: false)

    switch.trigger('click')
  end
end
