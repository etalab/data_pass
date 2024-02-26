Before do |scenario|
  Bullet.enable = scenario.source_tag_names.exclude?('@DisableBullet')
end

After do
  Bullet.enable = true
end
