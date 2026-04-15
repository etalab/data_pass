class MaintenanceBanner
  def self.active?
    Time.zone.now.between?(config[:start], config[:end])
  end

  def self.title = config[:title]
  def self.description = config[:description]

  def self.config
    Rails.application.config_for(:maintenance_banner)
  end
  private_class_method :config
end
