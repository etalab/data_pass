module DSFR::Pictogram
  def dsfr_pictogram(image_name)
    template.content_tag(:svg, aria: { hidden: true }, class: 'fr-artwork', viewBox: '0 0 80 80', width: '80px', height: '80px') do
      %w[decorative minor major].map { |type|
        template.content_tag(:use, '', href: "#{image_path(image_name)}#artwork-#{type}", class: "fr-artwork-#{type}")
      }.join.html_safe
    end
  end

  def dsfr_custom_pictogram(image_name)
    content_tag(:div, class: 'fr-custom-artwork') do
      image_tag(image_name)
    end
  end
end
