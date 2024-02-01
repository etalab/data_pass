module DSFR::Pictogram
  def dsfr_pictogram(image_name)
    template.content_tag(:svg, aria: { hidden: true }, class: 'fr-artwork', viewBox: '0 0 80 80', width: '80px', height: '80px') do
      %w[decorative minor major].map do |type|
        template.content_tag(:use, '', 'href': "#{image_path(image_name)}#artwork-#{type}", class: "fr-artwork-#{type}")
      end.join.html_safe
    end
  end
end
